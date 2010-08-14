module Gollum
  class Wiki
    include Pagination

    class << self
      # Sets the page class used by all instances of this Wiki.
      attr_writer :page_class

      # Sets the file class used by all instances of this Wiki.
      attr_writer :file_class

      # Gets the page class used by all instances of this Wiki.
      # Default: Gollum::Page.
      def page_class
        @page_class ||
          if superclass.respond_to?(:page_class)
            superclass.page_class
          else
            ::Gollum::Page
          end
      end

      # Gets the file class used by all instances of this Wiki.
      # Default: Gollum::File.
      def file_class
        @file_class ||
          if superclass.respond_to?(:file_class)
            superclass.file_class
          else
            ::Gollum::File
          end
      end
    end


    # The String base path to prefix to internal links. For example, when set
    # to "/wiki", the page "Hobbit" will be linked as "/wiki/Hobbit". Defaults
    # to "/".
    attr_reader :base_path

    # Public: Initialize a new Gollum Repo.
    #
    # repo    - The String path to the Git repository that holds the Gollum
    #           site.
    # options - Optional Hash:
    #           :base_path  - String base path for all Wiki links.  
    #                         Default: "/"
    #           :page_class - The page Class. Default: Gollum::Page
    #           :file_class - The file Class. Default: Gollum::File
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path, options = {})
      @path       = path
      @repo       = Grit::Repo.new(path)
      @base_path  = options[:base_path]  || "/"
      @page_class = options[:page_class] || self.class.page_class
      @file_class = options[:file_class] || self.class.file_class
    end

    # Public: check whether the wiki's git repo exists on the filesystem.
    #
    # Returns true if the repo exists, and false if it does not.
    def exist?
      @repo.git.exist?
    end

    # Public: Get the formatted page for a given page name.
    #
    # name    - The human or canonical String page name of the wiki page.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def page(name, version = 'master')
      @page_class.new(self).find(name, version)
    end

    # Public: Get the static file for a given name.
    #
    # name    - The full String pathname to the file.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::File or nil if no matching file was found.
    def file(name, version = 'master')
      @file_class.new(self).find(name, version)
    end

    # Public: Create an in-memory Page with the given data and format. This
    # is useful for previewing what content will look like before committing
    # it to the repository.
    #
    # name   - The String name of the page.
    # format - The Symbol format of the page.
    # data   - The new String contents of the page.
    #
    # Returns the in-memory Gollum::Page.
    def preview_page(name, data, format)
      page = @page_class.new(self)
      ext  = @page_class.format_to_ext(format.to_sym)
      path = @page_class.cname(name) + '.' + ext
      blob = OpenStruct.new(:name => path, :data => data)
      page.populate(blob, path)
      page.version = self.repo.commit("HEAD")
      page
    end

    # Public: Write a new version of a page to the Gollum repo root.
    #
    # name   - The String name of the page.
    # format - The Symbol format of the page.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def write_page(name, format, data, commit = {})
      map = {}
      if pcommit = @repo.commit('master')
        map = tree_map(pcommit.tree)
      end

      map   = add_to_tree_map(map, '', name, format, data)
      index = tree_map_to_index(map)

      parents = pcommit ? [pcommit] : []
      actor   = Grit::Actor.new(commit[:name], commit[:email])
      index.commit(commit[:message], parents, actor)
    end

    # Public: Update an existing page with new content. The location of the
    # page inside the repository will not change. If the given format is
    # different than the current format of the page, the filename will be
    # changed to reflect the new format.
    #
    # page   - The Gollum::Page to update.
    # name   - The String extension-less name of the page.
    # format - The Symbol format of the page.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def update_page(page, name, format, data, commit = {})
      pcommit  = @repo.commit('master')
      map      = tree_map(pcommit.tree)
      name   ||= page.name
      format ||= page.format
      index    = nil

      if page.name == name && page.format == format
        index = tree_map_to_index(map)
        index.add(page.path, normalize(data))
      else
        map   = delete_from_tree_map(map, page.path)
        dir   = ::File.dirname(page.path)
        map   = add_to_tree_map(map, dir, name, format, data)
        index = tree_map_to_index(map)
      end

      actor = Grit::Actor.new(commit[:name], commit[:email])
      index.commit(commit[:message], [pcommit], actor)
    end

    # Public: Delete a page.
    #
    # page   - The Gollum::Page to delete.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :author  - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def delete_page(page, commit)
      pcommit = @repo.commit('master')
      map     = tree_map(pcommit.tree)

      map   = delete_from_tree_map(map, page.path)
      index = tree_map_to_index(map)

      actor = Grit::Actor.new(commit[:name], commit[:email])
      index.commit(commit[:message], [pcommit], actor)
    end

    # Public: Lists all pages for this wiki.
    #
    # treeish - The String commit ID or ref to find  (default: master)
    #
    # Returns an Array of Gollum::Page instances.
    def pages(treeish = nil)
      treeish ||= 'master'
      if commit = @repo.commit(treeish)
        tree_list(commit)
      else
        []
      end
    end

    # Public: All of the versions that have touched the Page.
    #
    # options - The options Hash:
    #           :page     - The Integer page number (default: 1).
    #           :per_page - The Integer max count of items to return.
    #
    # Returns an Array of Grit::Commit.
    def log(options = {})
      @repo.log('master', nil, log_pagination_options(options))
    end

    #########################################################################
    #
    # Internal Methods
    #
    #########################################################################

    # The Grit::Repo associated with the wiki.
    #
    # Returns the Grit::Repo.
    attr_reader :repo

    # The String path to the Git repository that holds the Gollum site.
    #
    # Returns the String path.
    attr_reader :path

    # Normalize the data.
    #
    # data - The String data to be normalized.
    #
    # Returns the normalized data String.
    def normalize(data)
      data.gsub(/\r/, '')
    end

    # Fill an array with a list of pages.
    #
    # commit   - The Grit::Commit 
    # tree     - The Grit::Tree to start with.
    # sub_tree - Optional String specifying the parent path of the Page.
    #
    # Returns a flat Array of Gollum::Page instances.
    def tree_list(commit, tree = commit.tree, sub_tree = nil)
      list = []
      path = tree.name ? "#{sub_tree}/#{tree.name}" : ''
      tree.contents.each do |item|
        case item
          when Grit::Blob
            if @page_class.valid_page_name?(item.name)
              page = @page_class.new(self).populate(item, path)
              page.version = commit
              list << page
            end
          when Grit::Tree
            list.push *tree_list(commit, item, path)
        end
      end
      list
    end

    # Fill an index with the existing state of the repository.
    #
    # tree - The Grit::Tree to start with.
    #
    # Returns a nested Hash of filename to content mappings.
    def tree_map(tree)
      map = {}
      tree.contents.each do |item|
        case item
          when Grit::Blob
            map[item.name] = item.data
          when Grit::Tree
            map[item.name] = tree_map(item)
        end
      end
      map
    end

    # Use a treemap to fill in the index.
    #
    # map   - The Hash map:
    #         key - The String directory or filename.
    #         val - The Hash submap or the String contents of the file.
    # index - The Grit::Index to use. Leave blank when calling from outside
    #         this method (default: nil).
    #
    # Returns the Grit::Index.
    def tree_map_to_index(map, prefix = '', index = nil)
      index ||= @repo.index
      map.each do |k, v|
        case k
          when String
            name = [prefix, k].join('/')[1..-1]
            index.add(k, v)
          when Hash
            new_prefix = [prefix, k].join('/')[1..-1]
            tree_map_to_index(v, new_prefix, index)
        end
      end
      index
    end

    def add_to_tree_map(map, dir, name, format, data)
      ext  = @page_class.format_to_ext(format)
      path = @page_class.cname(name) + '.' + ext

      parts = dir.split('/')
      container = nil
      parts.each do |part|
        container = map[part]
      end

      (container || map)[path] = normalize(data)
      map
    end

    # Delete an entry from a tree map.
    #
    # map  - The Hash tree map of the repository.
    # path - The String path of the file to delete.
    #
    # Returns the modified Hash tree map.
    def delete_from_tree_map(map, path)
      parts = path.split('/')
      name  = parts.pop
      container = nil
      parts.each do |part|
        container = map[part]
      end
      (container || map).delete(name)
      map
    end
  end
end
