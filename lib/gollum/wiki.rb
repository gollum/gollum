module Gollum
  class Wiki
    include Pagination

    class << self
      # Sets the page class used by all instances of this Wiki.
      attr_writer :page_class

      # Sets the file class used by all instances of this Wiki.
      attr_writer :file_class

      # Sets the default name for commits.
      attr_accessor :default_committer_name

      # Sets the default email for commits.
      attr_accessor :default_committer_email

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

    self.default_committer_name  = 'Anonymous'
    self.default_committer_email = 'anon@anon.com'

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
      clear_cache
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
      commit = normalize_commit(commit)
      index  = self.repo.index

      if pcommit = @repo.commit('master')
        index.read_tree(pcommit.tree.id)
      end

      add_to_index(index, '', name, format, data)

      parents = pcommit ? [pcommit] : []
      actor   = Grit::Actor.new(commit[:name], commit[:email])
      sha1    = index.commit(commit[:message], parents, actor)

      @ref_map.clear
      update_working_dir(index, '', name, format)

      sha1
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
      commit   = normalize_commit(commit)
      pcommit  = @repo.commit('master')
      name   ||= page.name
      format ||= page.format
      index    = self.repo.index

      dir = ::File.dirname(page.path)
      dir = '' if dir == '.'

      index.read_tree(pcommit.tree.id)

      if page.name == name && page.format == format
        index.add(page.path, normalize(data))
      else
        index.delete(page.path)
        add_to_index(index, dir, name, format, data, :allow_same_ext)
      end

      actor = Grit::Actor.new(commit[:name], commit[:email])
      sha1  = index.commit(commit[:message], [pcommit], actor)

      @ref_map.clear
      update_working_dir(index, dir, page.name, page.format)
      update_working_dir(index, dir, name, format)

      sha1
    end

    # Public: Delete a page.
    #
    # page   - The Gollum::Page to delete.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def delete_page(page, commit)
      pcommit = @repo.commit('master')

      index = self.repo.index
      index.read_tree(pcommit.tree.id)
      index.delete(page.path)

      dir = ::File.dirname(page.path)
      dir = '' if dir == '.'

      actor = Grit::Actor.new(commit[:name], commit[:email])
      sha1  = index.commit(commit[:message], [pcommit], actor)

      @ref_map.clear
      update_working_dir(index, dir, page.name, page.format)

      sha1
    end

    # Public: Lists all pages for this wiki.
    #
    # treeish - The String commit ID or ref to find  (default: master)
    #
    # Returns an Array of Gollum::Page instances.
    def pages(treeish = nil)
      tree_list(treeish || 'master')
    end

    # Public: Lists all pages for this wiki sorted by title.
    #
    # treeish - The String commit ID or ref to find  (default: master)
    #
    # Returns an Array of Gollum::Page instances.
    def pages_sorted_by_title(treeish = nil)
      tree_list(treeish || 'master').sort! do |x, y| 
        x.title.downcase <=> y.title.downcase
      end
    end

    # Public: Returns the number of pages accessible from a commit 
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns a Fixnum
    def size(ref = nil)
      tree_map_for(ref || 'master').inject(0) do |num, entry|
        num + (@page_class.valid_page_name?(entry.name) ? 1 : 0)
      end
    end

    # Public: Search all pages for this wiki.
    #
    # query - The string to search for
    #
    # Returns an Array with Objects of page name and count of matches
    def search(query)
      # See: http://github.com/Sirupsen/gollum/commit/f0a6f52bdaf6bee8253ca33bb3fceaeb27bfb87e
      search_output = @repo.git.grep({:c => query}, 'master')

      search_output.split("\n").collect do |line|
        result = line.split(':')
        file_name = Gollum::Page.canonicalize_filename(::File.basename(result[1]))

        {
          :count  => result[2].to_i,
          :name   => file_name
        }
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

    # Gets a Hash cache of refs to commit SHAs.
    #
    #   {"master" => "abc123", ...}
    #
    # Returns the Hash cache.
    attr_reader :ref_map

    # Gets a Hash cache of commit SHAs to a recursive tree of blobs.
    #
    #   {"abc123" => [["lib/foo.rb", "blob-sha"], [file, sha], ...], ...}
    #
    # Returns the Hash cache.
    attr_reader :tree_map

    # Gets the page class used by all instances of this Wiki.
    attr_reader :page_class

    # Gets the file class used by all instances of this Wiki.
    attr_reader :file_class

    # Normalize the data.
    #
    # data - The String data to be normalized.
    #
    # Returns the normalized data String.
    def normalize(data)
      data.gsub(/\r/, '')
    end

    # Assemble a Page's filename from its name and format.
    #
    # name   - The String name of the page (may be in human format).
    # format - The Symbol format of the page.
    #
    # Returns the String filename.
    def page_file_name(name, format)
      ext = @page_class.format_to_ext(format)
      @page_class.cname(name) + '.' + ext
    end

    # Update the given file in the repository's working directory if there
    # is a working directory present.
    #
    # index  - The Grit::Index with which to sync.
    # dir    - The String directory in which the file lives.
    # name   - The String name of the page (may be in human format).
    # format - The Symbol format of the page.
    #
    # Returns nothing.
    def update_working_dir(index, dir, name, format)
      unless @repo.bare
        path =
        if dir == ''
          page_file_name(name, format)
        else
          ::File.join(dir, page_file_name(name, format))
        end

        Dir.chdir(::File.join(@repo.path, '..')) do
          if file_path_scheduled_for_deletion?(index.tree, path)
            @repo.git.rm({'f' => true}, '--', path)
          else
            @repo.git.checkout({}, 'HEAD', '--', path)
          end
        end
      end
    end

    # Fill an array with a list of pages.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns a flat Array of Gollum::Page instances.
    def tree_list(ref)
      tree_map_for(ref).inject([]) do |list, entry|
        next list unless @page_class.valid_page_name?(entry.name)
        sha   = ref_map[ref]
        list << entry.page(self, @repo.commit(sha))
      end
    end

    # Determine if a given file is scheduled to be deleted in the next commit
    # for the given Index.
    #
    # map   - The Hash map:
    #         key - The String directory or filename.
    #         val - The Hash submap or the String contents of the file.
    # path - The String path of the file including extension.
    #
    # Returns the Boolean response.
    def file_path_scheduled_for_deletion?(map, path)
      parts = path.split('/')
      if parts.size == 1
        deletions = map.keys.select { |k| !map[k] }
        deletions.any? { |d| d == parts.first }
      else
        part = parts.shift
        if rest = map[part]
          file_path_scheduled_for_deletion?(rest, parts.join('/'))
        else
          false
        end
      end
    end

    # Determine if a given page (regardless of format) is scheduled to be
    # deleted in the next commit for the given Index.
    #
    # map   - The Hash map:
    #         key - The String directory or filename.
    #         val - The Hash submap or the String contents of the file.
    # path - The String path of the page file. This may include the format
    #         extension in which case it will be ignored.
    #
    # Returns the Boolean response.
    def page_path_scheduled_for_deletion?(map, path)
      parts = path.split('/')
      if parts.size == 1
        deletions = map.keys.select { |k| !map[k] }
        downfile = parts.first.downcase.sub(/\.\w+$/, '')
        deletions.any? { |d| d.downcase.sub(/\.\w+$/, '') == downfile }
      else
        part = parts.shift
        if rest = map[part]
          page_path_scheduled_for_deletion?(rest, parts.join('/'))
        else
          false
        end
      end
    end

    # Adds a page to the given Index.
    #
    # index  - The Grit::Index to which the page will be added.
    # dir    - The String subdirectory of the Gollum::Page without any
    #          prefix or suffix slashes (e.g. "foo/bar").
    # name   - The String Gollum::Page name.
    # format - The Symbol Gollum::Page format.
    # data   - The String wiki data to store in the tree map.
    # allow_same_ext - A Boolean determining if the tree map allows the same
    #                  filename with the same extension.
    #
    # Raises Gollum::DuplicatePageError if a matching filename already exists.
    # This way, pages are not inadvertently overwritten.
    #
    # Returns nothing (modifies the Index in place).
    def add_to_index(index, dir, name, format, data, allow_same_ext = false)
      path = page_file_name(name, format)

      dir = '/' if dir.strip.empty?

      fullpath = ::File.join(dir, path)
      fullpath = fullpath[1..-1] if fullpath =~ /^\//

      if index.current_tree && tree = index.current_tree / dir
        downpath = path.downcase.sub(/\.\w+$/, '')

        tree.blobs.each do |blob|
          next if page_path_scheduled_for_deletion?(index.tree, fullpath)
          file = blob.name.downcase.sub(/\.\w+$/, '')
          file_ext = ::File.extname(blob.name).sub(/^\./, '')
          if downpath == file && !(allow_same_ext && file_ext == ext)
            raise DuplicatePageError.new(dir, blob.name, path)
          end
        end
      end

      index.add(fullpath, normalize(data))
    end

    # Ensures a commit hash has all the required fields for a commit.
    #
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the commit Hash
    def normalize_commit(commit = {})
      commit[:name]  = default_committer_name  if commit[:name].to_s.empty?
      commit[:email] = default_committer_email if commit[:email].to_s.empty?
      commit
    end

    # Gets the default name for commits.
    def default_committer_name
      @default_committer_name ||= \
        @repo.config['user.name'] || self.class.default_committer_name
    end

    # Gets the default email for commits.
    def default_committer_email
      @default_committer_email ||= \
        @repo.config['user.email'] || self.class.default_committer_email
    end

    # Finds a full listing of files and their blob SHA for a given ref.  Each
    # listing is cached based on its actual commit SHA.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns an Array of BlobEntry instances.
    def tree_map_for(ref)
      sha = @ref_map[ref] || ref
      @tree_map[sha] || begin
        real_sha              = @repo.git.rev_list({:max_count=>1}, ref)
        @ref_map[ref]         = real_sha if real_sha != ref
        @tree_map[real_sha] ||= parse_tree_for(real_sha)
      end
    rescue Grit::GitRuby::Repository::NoSuchShaFound
      []
    end

    # Finds the full listing of files and their blob SHA for a given commit
    # SHA.  No caching or ref lookups are performed.
    #
    # sha - String commit SHA.
    #
    # Returns an Array of BlobEntry instances.
    def parse_tree_for(sha)
      tree  = @repo.git.native(:ls_tree, {:r => true, :z => true}, sha)
      items = []
      tree.split("\0").each do |line|
        items << parse_tree_line(line)
      end
      items
    end

    # Parses a line of output from the `ls-tree` command.
    #
    # line - A String line of output:
    #          "100644 blob 839c2291b30495b9a882c17d08254d3c90d8fb53	Home.md"
    #
    # Returns an Array of BlobEntry instances.
    def parse_tree_line(line)
      data, name = line.split("\t")
      mode, type, sha = data.split(' ')
      name = decode_git_path(name)
      BlobEntry.new sha, name
    end

    # Decode octal sequences (\NNN) in tree path names.
    #
    # path - String path name.
    #
    # Returns a decoded String.
    def decode_git_path(path)
      if path[0] == ?" && path[-1] == ?"
        path = path[1...-1]
        path.gsub!(/\\\d{3}/)   { |m| m[1..-1].to_i(8).chr }
      end
      path.gsub!(/\\[rn"\\]/) { |m| eval(%("#{m.to_s}")) }
      path
    end

    # Resets the ref and tree caches for this wiki.
    def clear_cache
      @ref_map  = {}
      @tree_map = {}
    end
  end
end
