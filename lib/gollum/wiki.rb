module Gollum
  class Wiki
    include Pagination

    class << self
      # Sets the page class used by all instances of this Wiki.
      attr_writer :page_class

      # Sets the file class used by all instances of this Wiki.
      attr_writer :file_class

      # Sets the markup class used by all instances of this Wiki.
      attr_writer :markup_classes

      # Sets the default ref for the wiki.
      attr_accessor :default_ref

      # Sets the default name for commits.
      attr_accessor :default_committer_name

      # Sets the default email for commits.
      attr_accessor :default_committer_email

      # Array of chars to substitute whitespace for when trying to locate file in git repo.
      attr_accessor :default_ws_subs

      # Sets sanitization options. Set to false to deactivate
      # sanitization altogether.
      attr_writer :sanitization

      # Sets sanitization options. Set to false to deactivate
      # sanitization altogether.
      attr_writer :history_sanitization

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

      # Gets the markup class used by all instances of this Wiki.
      # Default: Gollum::Markup
      def markup_classes
        @markup_classes ||=
          if superclass.respond_to?(:markup_classes)
            superclass.markup_classes
          else
            Hash.new(::Gollum::Markup)
          end
      end

      # Gets the default markup class used by all instances of this Wiki.
      # Kept for backwards compatibility until Gollum v2.x
      def markup_class(language=:default)
        markup_classes[language]
      end

      # Sets the default markup class used by all instances of this Wiki.
      # Kept for backwards compatibility until Gollum v2.x
      def markup_class=(default)
        @markup_classes = Hash.new(default).update(markup_classes)
        default
      end

      alias_method :default_markup_class, :markup_class
      alias_method :default_markup_class=, :markup_class=

      # Gets the default sanitization options for current pages used by
      # instances of this Wiki.
      def sanitization
        if @sanitization.nil?
          @sanitization = Sanitization.new
        end
        @sanitization
      end

      # Gets the default sanitization options for older page revisions used by
      # instances of this Wiki.
      def history_sanitization
        if @history_sanitization.nil?
          @history_sanitization = sanitization ?
            sanitization.history_sanitization  :
            false
        end
        @history_sanitization
      end
    end

    self.default_ref = 'master'
    self.default_committer_name  = 'Anonymous'
    self.default_committer_email = 'anon@anon.com'

    self.default_ws_subs = ['_','-']

    # The String base path to prefix to internal links. For example, when set
    # to "/wiki", the page "Hobbit" will be linked as "/wiki/Hobbit". Defaults
    # to "/".
    attr_reader :base_path

    # Gets the sanitization options for current pages used by this Wiki.
    attr_reader :sanitization

    # Gets the sanitization options for older page revisions used by this Wiki.
    attr_reader :history_sanitization

    # Gets the String ref in which all page files reside.
    attr_reader :ref

    # Gets the String directory in which all page files reside.
    attr_reader :page_file_dir

    # Gets the Array of chars to sub for ws in filenames.
    attr_reader :ws_subs

    # Public: Initialize a new Gollum Repo.
    #
    # path    - The String path to the Git repository that holds the Gollum
    #           site.
    # options - Optional Hash:
    #           :base_path     - String base path for all Wiki links.
    #                            Default: "/"
    #           :page_class    - The page Class. Default: Gollum::Page
    #           :file_class    - The file Class. Default: Gollum::File
    #           :markup_classes - A hash containing the markup Classes for each
    #                             document type. Default: { Gollum::Markup }
    #           :sanitization  - An instance of Sanitization.
    #           :page_file_dir - String the directory in which all page files reside
    #           :ref - String the repository ref to retrieve pages from
    #           :ws_subs       - Array of chars to sub for ws in filenames.
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path, options = {})
      if path.is_a?(GitAccess)
        options[:access] = path
        path             = path.path
      end
      @path          = path
      @repo_is_bare  = options[:repo_is_bare]
      @page_file_dir = options[:page_file_dir]
      @access        = options[:access]       || GitAccess.new(path, @page_file_dir, @repo_is_bare)
      @base_path     = options[:base_path]    || "/"
      @page_class    = options[:page_class]   || self.class.page_class
      @file_class    = options[:file_class]   || self.class.file_class
      @markup_classes = options[:markup_classes] || self.class.markup_classes
      @repo          = @access.repo
      @ref           = options[:ref] || self.class.default_ref
      @sanitization  = options[:sanitization] || self.class.sanitization
      @ws_subs       = options[:ws_subs] ||
        self.class.default_ws_subs
      @history_sanitization = options[:history_sanitization] ||
        self.class.history_sanitization
    end

    # Public: check whether the wiki's git repo exists on the filesystem.
    #
    # Returns true if the repo exists, and false if it does not.
    def exist?
      @access.exist?
    end

    # Public: Get the formatted page for a given page name.
    #
    # name    - The human or canonical String page name of the wiki page.
    # version - The String version ID to find (default: @ref).
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def page(name, version = @ref)
      @page_class.new(self).find(name, version)
    end

    # Public: Get the static file for a given name.
    #
    # name    - The full String pathname to the file.
    # version - The String version ID to find (default: @ref).
    #
    # Returns a Gollum::File or nil if no matching file was found.
    def file(name, version = @ref)
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
      name = @page_class.cname(name) + '.' + ext
      blob = OpenStruct.new(:name => name, :data => data)
      page.populate(blob)
      page.version = @access.commit('master')
      page
    end

    # Public: Write a new version of a page to the Gollum repo root.
    #
    # name   - The String name of the page.
    # format - The Symbol format of the page.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message   - The String commit message.
    #          :name      - The String author full name.
    #          :email     - The String email address.
    #          :parent    - Optional Grit::Commit parent to this update.
    #          :tree      - Optional String SHA of the tree to create the
    #                       index from.
    #          :committer - Optional Gollum::Committer instance.  If provided,
    #                       assume that this operation is part of batch of
    #                       updates and the commit happens later.
    #
    # Returns the String SHA1 of the newly written version, or the
    # Gollum::Committer instance if this is part of a batch update.
    def write_page(name, format, data, commit = {})
      multi_commit = false

      committer = if obj = commit[:committer]
        multi_commit = true
        obj
      else
        Committer.new(self, commit)
      end

      filename = Gollum::Page.cname(name)
      dir      = page_file_dir || ''

      committer.add_to_index(dir, filename, format, data)
      committer.after_commit do |index, sha|
        @access.refresh
        index.update_working_dir(dir, filename, format)
      end

      multi_commit ? committer : committer.commit
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
    #          :message   - The String commit message.
    #          :name      - The String author full name.
    #          :email     - The String email address.
    #          :parent    - Optional Grit::Commit parent to this update.
    #          :tree      - Optional String SHA of the tree to create the
    #                       index from.
    #          :committer - Optional Gollum::Committer instance.  If provided,
    #                       assume that this operation is part of batch of
    #                       updates and the commit happens later.
    #
    # Returns the String SHA1 of the newly written version, or the
    # Gollum::Committer instance if this is part of a batch update.
    def update_page(page, name, format, data, commit = {})
      name   ||= page.name
      format ||= page.format
      dir      = ::File.dirname(page.path)
      dir      = '' if dir == '.'
      filename = (rename = page.name != name) ?
        Gollum::Page.cname(name) : page.filename_stripped

      multi_commit = false

      committer = if obj = commit[:committer]
        multi_commit = true
        obj
      else
        Committer.new(self, commit)
      end

      if !rename && page.format == format
        committer.add(page.path, normalize(data))
      else
        committer.delete(page.path)
        committer.add_to_index(dir, filename, format, data, :allow_same_ext)
      end

      committer.after_commit do |index, sha|
        @access.refresh
        index.update_working_dir(dir, page.filename_stripped, page.format)
        index.update_working_dir(dir, filename, format)
      end

      multi_commit ? committer : committer.commit
    end

    # Public: Delete a page.
    #
    # page   - The Gollum::Page to delete.
    # commit - The commit Hash details:
    #          :message   - The String commit message.
    #          :name      - The String author full name.
    #          :email     - The String email address.
    #          :parent    - Optional Grit::Commit parent to this update.
    #          :tree      - Optional String SHA of the tree to create the
    #                       index from.
    #          :committer - Optional Gollum::Committer instance.  If provided,
    #                       assume that this operation is part of batch of
    #                       updates and the commit happens later.
    #
    # Returns the String SHA1 of the newly written version, or the
    # Gollum::Committer instance if this is part of a batch update.
    def delete_page(page, commit)
      multi_commit = false

      committer = if obj = commit[:committer]
        multi_commit = true
        obj
      else
        Committer.new(self, commit)
      end

      committer.delete(page.path)

      committer.after_commit do |index, sha|
        dir = ::File.dirname(page.path)
        dir = '' if dir == '.'

        @access.refresh
        index.update_working_dir(dir, page.filename_stripped, page.format)
      end

      multi_commit ? committer : committer.commit
    end

    # Public: Applies a reverse diff for a given page.  If only 1 SHA is given,
    # the reverse diff will be taken from its parent (^SHA...SHA).  If two SHAs
    # are given, the reverse diff is taken from SHA1...SHA2.
    #
    # page   - The Gollum::Page to delete.
    # sha1   - String SHA1 of the earlier parent if two SHAs are given,
    #          or the child.
    # sha2   - Optional String SHA1 of the child.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #          :parent  - Optional Grit::Commit parent to this update.
    #
    # Returns a String SHA1 of the new commit, or nil if the reverse diff does
    # not apply.
    def revert_page(page, sha1, sha2 = nil, commit = {})
      if sha2.is_a?(Hash)
        commit = sha2
        sha2   = nil
      end

      patch     = full_reverse_diff_for(page, sha1, sha2)
      committer = Committer.new(self, commit)
      parent    = committer.parents[0]
      committer.options[:tree] = @repo.git.apply_patch(parent.sha, patch)
      return false unless committer.options[:tree]
      committer.after_commit do |index, sha|
        @access.refresh

        files = []
        if page
          files << [page.path, page.filename_stripped, page.format]
        else
          # Grit::Diff can't parse reverse diffs.... yet
          patch.each_line do |line|
            if line =~ %r{^diff --git b/.+? a/(.+)$}
              path = $1
              ext  = ::File.extname(path)
              name = ::File.basename(path, ext)
              if format = ::Gollum::Page.format_for(ext)
                files << [path, name, format]
              end
            end
          end
        end

        files.each do |(path, name, format)|
          dir = ::File.dirname(path)
          dir = '' if dir == '.'
          index.update_working_dir(dir, name, format)
        end
      end

      committer.commit
    end

    # Public: Applies a reverse diff to the repo.  If only 1 SHA is given,
    # the reverse diff will be taken from its parent (^SHA...SHA).  If two SHAs
    # are given, the reverse diff is taken from SHA1...SHA2.
    #
    # sha1   - String SHA1 of the earlier parent if two SHAs are given,
    #          or the child.
    # sha2   - Optional String SHA1 of the child.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :name    - The String author full name.
    #          :email   - The String email address.
    #
    # Returns a String SHA1 of the new commit, or nil if the reverse diff does
    # not apply.
    def revert_commit(sha1, sha2 = nil, commit = {})
      revert_page(nil, sha1, sha2, commit)
    end

    # Public: Lists all pages for this wiki.
    #
    # treeish - The String commit ID or ref to find  (default:  @ref)
    #
    # Returns an Array of Gollum::Page instances.
    def pages(treeish = nil)
      tree_list(treeish || @ref)
    end

    # Public: Returns the number of pages accessible from a commit
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns a Fixnum
    def size(ref = nil)
      tree_map_for(ref || @ref).inject(0) do |num, entry|
        num + (@page_class.valid_page_name?(entry.name) ? 1 : 0)
      end
    rescue Grit::GitRuby::Repository::NoSuchShaFound
      0
    end

    # Public: Search all pages for this wiki.
    #
    # query - The string to search for
    #
    # Returns an Array with Objects of page name and count of matches
    def search(query)
      args = [{}, '-i', '-c', query, @ref, '--']
      args << '--' << @page_file_dir if @page_file_dir

      @repo.git.grep(*args).split("\n").map! do |line|
        result = line.split(':')
        file_name = Gollum::Page.canonicalize_filename(::File.basename(result[1]))

        {
          :count  => result[2].to_i,
          :name   => file_name,
          :path   => result[1]
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
      @repo.log(@ref, nil, log_pagination_options(options))
    end

    # Public: Refreshes just the cached Git reference data.  This should
    # be called after every Gollum update.
    #
    # Returns nothing.
    def clear_cache
      @access.refresh
    end

    # Public: Creates a Sanitize instance using the Wiki's sanitization
    # options.
    #
    # Returns a Sanitize instance.
    def sanitizer
      if options = sanitization
        @sanitizer ||= options.to_sanitize
      end
    end

    # Public: Creates a Sanitize instance using the Wiki's history sanitization
    # options.
    #
    # Returns a Sanitize instance.
    def history_sanitizer
      if options = history_sanitization
        @history_sanitizer ||= options.to_sanitize
      end
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

    # Gets the page class used by all instances of this Wiki.
    attr_reader :page_class

    # Gets the file class used by all instances of this Wiki.
    attr_reader :file_class

    # Gets the markup class used by all instances of this Wiki.
    attr_reader :markup_classes

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
    # name   - The String name of the page (should be pre-canonicalized).
    # format - The Symbol format of the page.
    #
    # Returns the String filename.
    def page_file_name(name, format)
      name + '.' + @page_class.format_to_ext(format)
    end

    # Fill an array with a list of pages.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns a flat Array of Gollum::Page instances.
    def tree_list(ref)
      if sha = @access.ref_to_sha(ref)
        commit = @access.commit(sha)
        tree_map_for(sha).inject([]) do |list, entry|
          next list unless @page_class.valid_page_name?(entry.name)
          list << entry.page(self, commit)
        end
      else
        []
      end
    end

    # Creates a reverse diff for the given SHAs on the given Gollum::Page.
    #
    # page   - The Gollum::Page to scope the patch to, or a String Path.
    # sha1   - String SHA1 of the earlier parent if two SHAs are given,
    #          or the child.
    # sha2   - Optional String SHA1 of the child.
    #
    # Returns a String of the reverse Diff to apply.
    def full_reverse_diff_for(page, sha1, sha2 = nil)
      sha1, sha2 = "#{sha1}^", sha1 if sha2.nil?
      args = [{:R => true}, sha1, sha2]
      if page
        args << '--' << (page.respond_to?(:path) ? page.path : page.to_s)
      end
      repo.git.native(:diff, *args)
    end

    # Creates a reverse diff for the given SHAs.
    #
    # sha1   - String SHA1 of the earlier parent if two SHAs are given,
    #          or the child.
    # sha2   - Optional String SHA1 of the child.
    #
    # Returns a String of the reverse Diff to apply.
    def full_reverse_diff(sha1, sha2 = nil)
      full_reverse_diff_for(nil, sha1, sha2)
    end

    # Gets the default name for commits.
    #
    # Returns the String name.
    def default_committer_name
      @default_committer_name ||= \
        @repo.config['user.name'] || self.class.default_committer_name
    end

    # Gets the default email for commits.
    #
    # Returns the String email address.
    def default_committer_email
      @default_committer_email ||= \
        @repo.config['user.email'] || self.class.default_committer_email
    end

    # Gets the commit object for the given ref or sha.
    #
    # ref - A string ref or SHA pointing to a valid commit.
    #
    # Returns a Grit::Commit instance.
    def commit_for(ref)
      @access.commit(ref)
    rescue Grit::GitRuby::Repository::NoSuchShaFound
    end

    # Finds a full listing of files and their blob SHA for a given ref.  Each
    # listing is cached based on its actual commit SHA.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns an Array of BlobEntry instances.
    def tree_map_for(ref)
      @access.tree(ref)
    rescue Grit::GitRuby::Repository::NoSuchShaFound
      []
    end

    def inspect
      %(#<#{self.class.name}:#{object_id} #{@repo.path}>)
    end
  end
end
