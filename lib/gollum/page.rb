module Gollum
  class Page
    include Pagination

    Wiki.page_class = self

    VALID_PAGE_RE = /^(.+)\.(md|mkdn?|mdown|markdown|textile|rdoc|org|creole|re?st(\.txt)?|asciidoc|pod)$/i
    FORMAT_NAMES = { :markdown => "Markdown",
                     :textile  => "Textile",
                     :rdoc     => "RDoc",
                     :org      => "Org-mode",
                     :creole   => "Creole",
                     :rest     => "reStructuredText",
                     :asciidoc => "AsciiDoc",
                     :pod      => "Pod" }

    # Checks if a filename has a valid extension understood by GitHub::Markup.
    #
    # filename - String filename, like "Home.md".
    #
    # Returns the matching String basename of the file without the extension.
    def self.valid_filename?(filename)
      filename && filename.to_s =~ VALID_PAGE_RE && $1
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

    # Reusable filter to turn a filename (without path) into a canonical name.
    # Strips extension, converts spaces to dashes.
    #
    # Returns the filtered String.
    def self.canonicalize_filename(filename)
      filename.split('.')[0..-2].join('.').gsub('-', ' ')
    end

    # Public: Initialize a page.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::Page.
    def initialize(wiki)
      @wiki = wiki
      @blob = nil
    end

    # Public: The on-disk filename of the page including extension.
    #
    # Returns the String name.
    def filename
      @blob && @blob.name
    end

    # Public: The canonical page name without extension, and dashes converted 
    # to spaces.
    #
    # Returns the String name.
    def name
      self.class.canonicalize_filename(filename)
    end

    # Public: If the first element of a formatted page is an <h1> tag it can
    # be considered the title of the page and used in the display. If the
    # first element is NOT an <h1> tag, the title will be constructed from the
    # filename by stripping the extension and replacing any dashes with
    # spaces.
    #
    # Returns the fully sanitized String title.
    def title
      doc = Nokogiri::HTML(%{<div id="gollum-root">} + self.formatted_data + %{</div>})

      header =
      case self.format
        when :asciidoc
          doc.css("div#gollum-root > div#header > h1:first-child")
        when :org
          doc.css("div#gollum-root > p.title:first-child")
        when :pod
          doc.css("div#gollum-root > a.dummyTopAnchor:first-child + h1")
        when :rest
          doc.css("div#gollum-root > div > div > h1:first-child")
        else
          doc.css("div#gollum-root > h1:first-child")
      end

      if !header.empty?
        Sanitize.clean(header.to_html)
      else
        Sanitize.clean(name)
      end
    end

    # Public: The path of the page within the repo.
    #
    # Returns the String path.
    attr_reader :path

    # Public: The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      @blob && @blob.data
    end

    # Public: The formatted contents of the page.
    #
    # Returns the String data.
    def formatted_data
      @blob && Gollum::Markup.new(self).render
    end

    # Public: The format of the page.
    #
    # Returns the Symbol format of the page. One of:
    #   [ :markdown | :textile | :rdoc | :org | :rest | :asciidoc | :pod |
    #     :roff ]
    def format
      case @blob.name
        when /\.(md|mkdn?|mdown|markdown)$/i
          :markdown
        when /\.(textile)$/i
          :textile
        when /\.(rdoc)$/i
          :rdoc
        when /\.(org)$/i
          :org
        when /\.(creole)$/i
          :creole
        when /\.(re?st(\.txt)?)$/i
          :rest
        when /\.(asciidoc)$/i
          :asciidoc
        when /\.(pod)$/i
          :pod
        when /\.(\d)$/i
          :roff
        else
          nil
      end
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
        log = @wiki.repo.git.native "log", options, "master", "--", @path
        Grit::Commit.list_from_string(@wiki.repo, log)
      else
        @wiki.repo.log('master', @path, log_pagination_options(options))
      end
    end

    # Public: The footer Page.
    #
    # Returns the footer Page or nil if none exists.
    def footer
      return nil if page_match('_Footer', self.filename)

      dirs = self.path.split('/')
      dirs.pop
      map = @wiki.tree_map_for(self.version.id)
      while !dirs.empty?
        if page = find_page_in_tree(map, '_Footer', dirs.join('/'))
          return page
        end
        dirs.pop
      end

      find_page_in_tree(map, '_Footer', '')
    end

    #########################################################################
    #
    # Class Methods
    #
    #########################################################################

    # Convert a human page name into a canonical page name.
    #
    # name - The String human page name.
    #
    # Examples
    #
    #   Page.cname("Bilbo Baggins")
    #   # => 'Bilbo-Baggins'
    #
    # Returns the String canonical name.
    def self.cname(name)
      name.respond_to?(:gsub)      ?
        name.gsub(%r{[ /<>]}, '-') :
        ''
    end

    # Convert a format Symbol into an extension String.
    #
    # format - The format Symbol.
    #
    # Returns the String extension (no leading period).
    def self.format_to_ext(format)
      case format
        when :markdown then 'md'
        when :textile  then 'textile'
        when :rdoc     then 'rdoc'
        when :org      then 'org'
        when :creole   then 'creole'
        when :rest     then 'rest'
        when :asciidoc then 'asciidoc'
        when :pod      then 'pod'
      end
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
    def find(name, version)
      map = @wiki.tree_map_for(version)
      if page = find_page_in_tree(map, name)
        sha = @wiki.ref_map[version] || version
        page.version = Grit::Commit.create(@wiki.repo, :id => sha)
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
    def find_page_in_tree(map, name, checked_dir = nil)
      return nil if name.to_s.empty?
      if checked_dir = BlobEntry.normalize_dir(checked_dir)
        checked_dir.downcase!
      end

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
    def populate(blob, path)
      @blob = blob
      @path = (path + '/' + blob.name)[1..-1]
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
        Page.cname(name).downcase == Page.cname(match).downcase
      else
        false
      end
    end
  end
end