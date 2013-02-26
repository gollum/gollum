# ~*~ encoding: utf-8 ~*~
module Gollum
  class Page
    include Pagination

    Wiki.page_class = self

    # Sets a Boolean determing whether this page is a historical version.
    #
    # Returns nothing.
    attr_writer :historical

    # Parent page if this is a sub page
    #
    # Returns a Page
    attr_accessor :parent_page


    # Checks a filename against the registered markup extensions
    #
    # filename - String filename, like "Home.md"
    #
    # Returns e.g. ["Home", :markdown], or [] if the extension is unregistered
    def self.parse_filename(filename)
      return [] unless filename =~ /^(.+)\.([a-zA-Z]\w*)$/i
      pref, ext = $1, $2

      Gollum::Markup.formats.each_pair do |name, format|
        return [pref, name] if ext =~ format[:regexp]
      end
      []
    end

    # Checks if a filename has a valid, registered extension
    #
    # filename - String filename, like "Home.md".
    #
    # Returns the matching String basename of the file without the extension.
    def self.valid_filename?(filename)
      self.parse_filename(filename).first
    end

    # Checks if a filename has a valid extension understood by GitHub::Markup.
    # Also, checks if the filename has no "_" in the front (such as
    # _Footer.md).
    #
    # filename - String filename, like "Home.md".
    #
    # Returns the matching String basename of the file without the extension.
    def self.valid_page_name?(filename)
      match = valid_filename?(filename)
      filename =~ /^_/ ? false : match
    end

    # Public: The format of a given filename.
    #
    # filename - The String filename.
    #
    # Returns the Symbol format of the page; one of the registered format types
    def self.format_for(filename)
      self.parse_filename(filename).last
    end

    # Reusable filter to turn a filename (without path) into a canonical name.
    # Strips extension, converts dashes to spaces.
    #
    # Returns the filtered String.
    def self.canonicalize_filename(filename)
      strip_filename(filename).gsub('-', ' ')
    end

    # Reusable filter to strip extension and path from filename
    #
    # filename - The string path or filename to strip
    #
    # Returns the stripped String.
    def self.strip_filename(filename)
      ::File.basename(filename, ::File.extname(filename))
    end

    # Public: Initialize a page.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::Page.
    def initialize(wiki)
      @wiki = wiki
      @blob = @header = @footer = @sidebar = nil
      @doc = nil
      @parent_page = nil
    end

    # Public: The on-disk filename of the page including extension.
    #
    # Returns the String name.
    def filename
      @blob && @blob.name
    end

    # Public: The on-disk filename of the page with extension stripped.
    #
    # Returns the String name.
    def filename_stripped
      self.class.strip_filename(filename)
    end

    # Public: The canonical page name without extension, and dashes converted
    # to spaces.
    #
    # Returns the String name.
    def name
      self.class.canonicalize_filename(filename)
    end

    # Public: The title will be constructed from the
    # filename by stripping the extension and replacing any dashes with
    # spaces.
    #
    # Returns the fully sanitized String title.
    def title
      Sanitize.clean(name).strip
    end

    # Public: Determines if this is a sub-page
    # Sub-pages have filenames beginning with an underscore
    #
    # Returns true or false.
    def sub_page
      filename =~ /^_/
    end

    # Public: The path of the page within the repo.
    #
    # Returns the String path.
    attr_reader :path

    # Public: The url path required to reach this page within the repo.
    #
    # Returns the String url_path
    def url_path
      path = if self.path.include?('/')
        self.path.sub(/\/[^\/]+$/, '/')
      else
        ''
      end

      path << Page.cname(self.name, '-', '-')
      path
    end

    # Public: Defines title for page.rb
    #
    # Returns the String title
    def url_path_title
      metadata_title || url_path.gsub("-", " ")
    end

    # Public: Metadata title
    #
    # Set with <!-- --- title: New Title --> in page content
    #
    # Returns the String title or nil if not defined
    def metadata_title
      if metadata
        title = metadata['title']
        return title unless title.nil?
      end

      nil
    end

    # Public: The url_path, but CGI escaped.
    #
    # Returns the String url_path
    def escaped_url_path
      CGI.escape(self.url_path).gsub('%2F','/')
    end

    # Public: The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      @blob && @blob.data
    end

    # Public: A text data encoded in specified encoding.
    #
    # encoding - An Encoding or nil
    #
    # Returns a character encoding aware String.
    def text_data(encoding=nil)
      if raw_data.respond_to?(:encoding)
        raw_data.force_encoding(encoding || Encoding::UTF_8)
      else
        raw_data
      end
    end

    # Public: The formatted contents of the page.
    #
    # encoding - Encoding Constant or String.
    #
    # Returns the String data.
    def formatted_data(encoding = nil, &block)
      @blob && markup_class.render(historical?, encoding) do |doc|
        @doc = doc
        yield doc if block_given?
      end
    end

    # Public: The table of contents of the page.
    #
    # formatted_data - page already marked up in html.
    #
    # Returns the String data.
    def toc_data()
      return @parent_page.toc_data if @parent_page and @sub_page
      formatted_data if markup_class.toc == nil
      markup_class.toc
    end

    # Public: Embedded metadata.
    #
    # Returns Hash of metadata.
    def metadata()
      formatted_data if markup_class.metadata == nil
      markup_class.metadata
    end

    # Public: The format of the page.
    #
    # Returns the Symbol format of the page; one of the registered format types
    def format
      self.class.format_for(@blob.name)
    end

    # Gets the Gollum::Markup instance that will render this page's content.
    #
    # Returns a Gollum::Markup instance.
    def markup_class
      @markup_class ||= @wiki.markup_classes[format].new(self)
    end

    # Public: The current version of the page.
    #
    # Returns the Grit::Commit.
    attr_reader :version

    # Public: All of the versions that have touched the Page.
    #
    # options - The options Hash:
    #           :page     - The Integer page number (default: 1).
    #           :per_page - The Integer max count of items to return.
    #           :follow   - Follow's a file across renames, but falls back
    #                       to a slower Grit native call.  (default: false)
    #
    # Returns an Array of Grit::Commit.
    def versions(options = {})
      if options[:follow]
        options[:pretty] = 'raw'
        options.delete :max_count
        options.delete :skip
        log = @wiki.repo.git.native "log", options, @wiki.ref, "--", @path
        Grit::Commit.list_from_string(@wiki.repo, log)
      else
        @wiki.repo.log(@wiki.ref, @path, log_pagination_options(options))
      end
    end

    # Public: The first 7 characters of the current version.
    #
    # Returns the first 7 characters of the current version.
   def version_short
     version.to_s[0,7]
   end

    # Public: The header Page.
    #
    # Returns the header Page or nil if none exists.
    def header
      @header ||= find_sub_page(:header)
    end

    # Public: The footer Page.
    #
    # Returns the footer Page or nil if none exists.
    def footer
      @footer ||= find_sub_page(:footer)
    end

    # Public: The sidebar Page.
    #
    # Returns the sidebar Page or nil if none exists.
    def sidebar
      @sidebar ||= find_sub_page(:sidebar)
    end

    # Gets a Boolean determining whether this page is a historical version.
    # Historical pages are pulled using exact SHA hashes and format all links
    # with rel="nofollow"
    #
    # Returns true if the page is pulled from a named branch or tag, or false.
    def historical?
      !!@historical
    end

    #########################################################################
    #
    # Class Methods
    #
    #########################################################################

    # Convert a human page name into a canonical page name.
    #
    # name           - The String human page name.
    # char_white_sub - Substitution for whitespace
    # char_other_sub - Substitution for other special chars
    #
    # Examples
    #
    #   Page.cname("Bilbo Baggins")
    #   # => 'Bilbo-Baggins'
    #
    #   Page.cname("Bilbo Baggins",'_')
    #   # => 'Bilbo_Baggins'
    #
    # Returns the String canonical name.
    def self.cname(name, char_white_sub = '-', char_other_sub = '-')
      name.respond_to?(:gsub) ?
        name.gsub(%r{\s},char_white_sub).gsub(%r{[<>+]}, char_other_sub) :
        ''
    end

    # Convert a format Symbol into an extension String.
    #
    # format - The format Symbol.
    #
    # Returns the String extension (no leading period).
    def self.format_to_ext(format)
      format == :markdown ? "md" : format.to_s
    end

    #########################################################################
    #
    # Internal Methods
    #
    #########################################################################

    # The underlying wiki repo.
    #
    # Returns the Gollum::Wiki containing the page.
    attr_reader :wiki

    # Set the Grit::Commit version of the page.
    #
    # Returns nothing.
    attr_writer :version

    # Find a page in the given Gollum repo.
    #
    # name    - The human or canonical String page name to find.
    # version - The String version ID to find.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find(name, version, dir = nil, exact = false)
      map = @wiki.tree_map_for(version.to_s)
      if page = find_page_in_tree(map, name, dir, exact)
        page.version    = version.is_a?(Grit::Commit) ?
          version : @wiki.commit_for(version)
        page.historical = page.version.to_s == version.to_s
        page
      end
    rescue Grit::GitRuby::Repository::NoSuchShaFound
    end

    # Find a page in a given tree.
    #
    # map         - The Array tree map from Wiki#tree_map.
    # name        - The canonical String page name.
    # checked_dir - Optional String of the directory a matching page needs
    #               to be in.  The string should
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find_page_in_tree(map, name, checked_dir = nil, exact = false)
      return nil if !map || name.to_s.empty?
      if checked_dir = BlobEntry.normalize_dir(checked_dir)
        checked_dir.downcase!
      end

      checked_dir = '' if exact && checked_dir.nil?

      map.each do |entry|
        next if entry.name.to_s.empty?
        next unless checked_dir.nil? || entry.dir.downcase == checked_dir
        next unless page_match(name, entry.name)
        return entry.page(@wiki, @version)
      end

      return nil # nothing was found
    end

    # Populate the Page with information from the Blob.
    #
    # blob - The Grit::Blob that contains the info.
    # path - The String directory path of the page file.
    #
    # Returns the populated Gollum::Page.
    def populate(blob, path=nil)
      @blob = blob
      @path = "#{path}/#{blob.name}"[1..-1]
      self
    end

    # The full directory path for the given tree.
    #
    # treemap - The Hash treemap containing parentage information.
    # tree    - The Grit::Tree for which to compute the path.
    #
    # Returns the String path.
    def tree_path(treemap, tree)
      if ptree = treemap[tree]
        tree_path(treemap, ptree) + '/' + tree.name
      else
        ''
      end
    end

    # Compare the canonicalized versions of the two names.
    #
    # name     - The human or canonical String page name.
    # filename - the String filename on disk (including extension).
    #
    # Returns a Boolean.
    def page_match(name, filename)
      if match = self.class.valid_filename?(filename)
        @wiki.ws_subs.each do |sub|
          return true if Page.cname(name).downcase == Page.cname(match, sub).downcase
        end
      end
      false
    end

    # Loads a sub page.  Sub page names (footers, headers, sidebars) are prefixed with
    # an underscore to distinguish them from other Pages. If there is not one within
    # the current directory, starts walking up the directory tree to try and find one
    # within parent directories.
    #
    # name - String page name.
    #
    # Returns the Page or nil if none exists.
    def find_sub_page(name)
      return nil unless self.version
      return nil if self.filename =~ /^_/
      name = "_#{name.to_s.capitalize}"
      return nil if page_match(name, self.filename)

      dirs = self.path.split('/')
      dirs.pop
      map = @wiki.tree_map_for(@wiki.ref, true)
      while !dirs.empty?
        if page = find_page_in_tree(map, name, dirs.join('/'))
          page.parent_page = self
          return page
        end
        dirs.pop
      end

      if page = find_page_in_tree(map, name, '')
        page.parent_page = self
      end
      page
    end

    def inspect
      %(#<#{self.class.name}:#{object_id} #{name} (#{format}) @wiki=#{@wiki.repo.path.inspect}>)
    end
  end
end
