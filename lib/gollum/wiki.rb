module Gollum
  class Wiki
    # Public: Initialize a new Gollum Repo.
    #
    # repo - The String path to the Git repository that holds the Gollum site.
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path)
      @path = path
      @repo = Grit::Repo.new(path)
    end

    # Public: Get the formatted page for a given page name.
    #
    # name    - The human or canonical String page name of the wiki page.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def page(name, version = 'master')
      Page.new(self).find(name, version)
    end

    # Public: Get the static file for a given name.
    #
    # name    - The full String pathname to the file.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::File or nil if no matching file was found.
    def file(name, version = 'master')
      File.new(self).find(name, version)
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
      ext = Page.format_to_ext(format)
      path = Gollum.canonical_name(name) + '.' + ext

      map = {}
      if pcommit = @repo.commit('master')
        map = tree_map(pcommit.tree)
      end
      map[path] = data
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
      index.add(page.path, data)

      actor = Grit::Actor.new(commit[:name], commit[:email])
      index.commit(commit[:message], [pcommit], actor)
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