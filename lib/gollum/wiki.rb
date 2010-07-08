module Gollum
  class Wiki
    include Pagination

    class << self
      attr_accessor :page_class, :file_class
    end

    # Public: Initialize a new Gollum Repo.
    #
    # repo    - The String path to the Git repository that holds the Gollum 
    #           site.
    # options - Optional Hash:
    #           :page_class - The page Class. Default: Gollum::Page
    #           :file_class - The file Class. Default: Gollum::File
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path, options = {})
      @path       = path
      @repo       = Grit::Repo.new(path)
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

    # Public: Write a new version of a page to the Gollum repo root.
    #
    # name   - The String name of the page.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def write_page(name, format, data, commit = {})
      ext  = @page_class.format_to_ext(format)
      path = @page_class.cname(name) + '.' + ext

      map = {}
      if pcommit = @repo.commit('master')
        map = tree_map(pcommit.tree)
      end
      map[path] = normalize(data)
      index = tree_map_to_index(map)

      parents = pcommit ? [pcommit] : []
      actor = Grit::Actor.new(commit[:name], commit[:email])
      index.commit(commit[:message], parents, actor)
    end

    # Public: Update an existing page with new content. The location of the
    # page inside the repository and the page's format will not change.
    #
    # page   - The Gollum::Page to update.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def update_page(page, data, commit = {})
      pcommit = @repo.commit('master')
      map = tree_map(pcommit.tree)
      index = tree_map_to_index(map)
      index.add(page.path, normalize(data))

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
      map = tree_map(pcommit.tree)

      parts = page.path.split('/')
      name = parts.pop
      container = nil
      parts.each do |part|
        container = map[part]
      end
      (container || map).delete(name)

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
      tree_list(@repo.commit(treeish).tree)
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
    # tree     - The Grit::Tree to start with.
    # sub_tree - Optional String specifying the parent path of the Page.
    #
    # Returns a flat Array of Gollum::Page instances.
    def tree_list(tree, sub_tree = nil)
      list = []
      path = tree.name ? "#{sub_tree}/#{tree.name}" : ''
      tree.contents.each do |item|
        case item
          when Grit::Blob
            list << @page_class.new(self).populate(item, path)
          when Grit::Tree
            list.push *tree_list(item, path)
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
  end
end