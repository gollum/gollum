# ~*~ encoding: utf-8 ~*~
require 'digest/sha1'
require 'cgi'
require 'pygments'
require 'base64'

require File.expand_path '../frontend/helpers', __FILE__
require File.expand_path '../gitcode', __FILE__

# initialize Pygments
Pygments.start

module Gollum

  class Markup
    include Precious::Helpers

    @formats = {}

    class << self
      attr_reader :formats

      # Register a file extension and associated markup type
      #
      # ext     - The file extension
      # name    - The name of the markup type
      # options - Hash of options:
      #           regexp - Regexp to match against.
      #                    Defaults to exact match of ext.
      #
      # If given a block, that block will be registered with GitHub::Markup to
      # render any matching pages
      def register(ext, name, options = {}, &block)
        regexp = options[:regexp] || Regexp.new(ext.to_s)
        @formats[ext] = { :name => name, :regexp => regexp }
        GitHub::Markup.add_markup(regexp, &block) if block_given?
      end
    end

    attr_accessor :toc
    attr_reader   :metadata

    # Initialize a new Markup object.
    #
    # page - The Gollum::Page.
    #
    # Returns a new Gollum::Markup object, ready for rendering.
    def initialize(page)
      @wiki    = page.wiki
      @name    = page.filename
      @data    = page.text_data
      @version = page.version.id if page.version
      @format  = page.format
      @sub_page = page.sub_page
      @parent_page = page.parent_page
      @dir     = ::File.dirname(page.path)
      @tagmap  = {}
      @codemap = {}
      @wsdmap  = {}
      @premap  = {}
      @toc = nil
      @metadata = nil
      @to_xml = { :save_with => Nokogiri::XML::Node::SaveOptions::DEFAULT_XHTML ^ 1, :indent => 0, :encoding => 'UTF-8' }
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # no_follow - Boolean that determines if rel="nofollow" is added to all
    #             <a> tags.
    # encoding  - Encoding Constant or String.
    #
    # Returns the formatted String content.
    def render(no_follow = false, encoding = nil)
      sanitize = no_follow ?
        @wiki.history_sanitizer :
        @wiki.sanitizer

      data = @data.dup
      data = extract_metadata(data)
      data = extract_gitcode(data)
      data = extract_code(data)
      data = extract_wsd(data)
      data = extract_tags(data)
      begin
        data = GitHub::Markup.render(@name, data)
        if data.nil?
          raise "There was an error converting #{@name} to HTML."
        end
      rescue Object => e
        data = %{<p class="gollum-error">#{e.message}</p>}
      end
      data = process_tags(data)
      data = process_code(data, encoding)

      doc = Nokogiri::HTML::DocumentFragment.parse(data)
      doc = sanitize.clean_node!(doc) if sanitize
      doc,toc = process_headers(doc)
      @toc = @sub_page ? ( @parent_page ? @parent_page.toc_data : "[[_TOC_]]" ) : toc
      yield doc if block_given?
      # nokogiri's save options are ored together. FORMAT has a value of 1 so ^ 1 removes it.
      # formatting will create extra spaces in pre tags.
      # https://github.com/sparklemotion/nokogiri/issues/782
      # DEFAULT_HTML encodes unicode so XHTML is used for proper unicode support in href.
      data = doc.to_xml( @to_xml )

      data = process_toc_tags(data)
      data = process_wsd(data)
      data.gsub!(/<p><\/p>/) do
        ''
      end

      data
    end

    # Inserts header anchors and creates TOC
    #
    # doc - Nokogiri parsed document
    #
    # Returns doc Document and toc String
    def process_headers(doc)
      toc = nil
      doc.css('h1,h2,h3,h4,h5,h6').each do |h|
        # must escape "
        h_name = h.content.gsub(' ','-').gsub('"','%22')

        level = h.name.gsub(/[hH]/,'').to_i

        # Add anchors
        h.add_child(%Q{<a class="anchor" id="#{h_name}" href="##{h_name}"></a>})

        # Build TOC
        toc ||= Nokogiri::XML::DocumentFragment.parse('<div class="toc"><div class="toc-title">Table of Contents</div></div>')
        tail ||= toc.child
        tail_level ||= 0

        while tail_level < level
          node = Nokogiri::XML::Node.new('ul', doc)
          tail = tail.add_child(node)
          tail_level += 1
        end          
        while tail_level > level
          tail = tail.parent
          tail_level -= 1
        end
        node = Nokogiri::XML::Node.new('li', doc)
        # % -> %25 so anchors work on Firefox. See issue #475
        node.add_child(%Q{<a href="##{h_name}">#{h.content}</a>})
        tail.add_child(node)
      end
      toc = toc.to_xml(@to_xml) if toc != nil
      [doc, toc]
    end

    #########################################################################
    #
    # Tags
    #
    #########################################################################

    # Extract all tags into the tagmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_tags(data)
      if @format == :asciidoc
        return data
      end
      data.gsub!(/(.?)\[\[(.+?)\]\]([^\[]?)/m) do
        if $1 == "'" && $3 != "'"
          "[[#{$2}]]#{$3}"
        elsif $2.include?('][')
          if $2[0..4] == 'file:'
            pre = $1
            post = $3
            parts = $2.split('][')
            parts[0][0..4] = ""
            link = "#{parts[1]}|#{parts[0].sub(/\.org/,'')}"
            id = Digest::SHA1.hexdigest(link)
            @tagmap[id] = link
            "#{pre}#{id}#{post}"
          else
            $&
          end
        else
          id = Digest::SHA1.hexdigest($2)
          @tagmap[id] = $2
          "#{$1}#{id}#{$3}"
        end
      end
      data
    end

    # Process all tags from the tagmap and replace the placeholders with the
    # final markup.
    #
    # data      - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_tags(data)
      @tagmap.each do |id, tag|
        # If it's preformatted, just put the tag back
        if is_preformatted?(data, id)
          data.gsub!(id) do
            "[[#{tag}]]"
          end
        else
          data.gsub!(id) do
            process_tag(tag).gsub('%2F', '/')
          end
        end
      end
      data
    end

    # Find `id` within `data` and determine if it's within
    # preformatted tags.
    #
    # data      - The String data (with placeholders).
    # id        - The String SHA1 hash.
    PREFORMATTED_TAGS = %w(code tt)
    def is_preformatted?(data, id)
      doc = Nokogiri::HTML::DocumentFragment.parse(data)
      node = doc.search("[text()*='#{id}']").first
      node && (PREFORMATTED_TAGS.include?(node.name) ||
        node.ancestors.any? { |a| PREFORMATTED_TAGS.include?(a.name) })
    end

    # Process a single tag into its final HTML form.
    #
    # tag       - The String tag contents (the stuff inside the double
    #             brackets).
    #
    # Returns the String HTML version of the tag.
    def process_tag(tag)
      if tag =~ /^_TOC_$/
        %{[[#{tag}]]}
      elsif html = process_image_tag(tag)
        html
      elsif html = process_file_link_tag(tag)
        html
      else
        process_page_link_tag(tag)
      end
    end

    # Attempt to process the tag as an image tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid image tag or nil
    #   if it is not.
    def process_image_tag(tag)
      parts = tag.split('|')
      return if parts.size.zero?

      name  = parts[0].strip
      path  = if file = find_file(name)
        ::File.join @wiki.base_path, file.path
      elsif name =~ /^https?:\/\/.+(jpg|png|gif|svg|bmp)$/i
        name
      end

      if path
        opts = parse_image_tag_options(tag)

        containered = false

        classes = [] # applied to whatever the outermost container is
        attrs   = [] # applied to the image

        align = opts['align']
        if opts['float']
          containered = true
          align ||= 'left'
          if %w{left right}.include?(align)
            classes << "float-#{align}"
          end
        elsif %w{top texttop middle absmiddle bottom absbottom baseline}.include?(align)
          attrs << %{align="#{align}"}
        elsif align
          if %w{left center right}.include?(align)
            containered = true
            classes << "align-#{align}"
          end
        end

        if width = opts['width']
          if width =~ /^\d+(\.\d+)?(em|px)$/
            attrs << %{width="#{width}"}
          end
        end

        if height = opts['height']
          if height =~ /^\d+(\.\d+)?(em|px)$/
            attrs << %{height="#{height}"}
          end
        end

        if alt = opts['alt']
          attrs << %{alt="#{alt}"}
        end

        attr_string = attrs.size > 0 ? attrs.join(' ') + ' ' : ''

        if opts['frame'] || containered
          classes << 'frame' if opts['frame']
          %{<span class="#{classes.join(' ')}">} +
          %{<span>} +
          %{<img src="#{path}" #{attr_string}/>} +
          (alt ? %{<span>#{alt}</span>} : '') +
          %{</span>} +
          %{</span>}
        else
          %{<img src="#{path}" #{attr_string}/>}
        end
      end
    end

    # Parse any options present on the image tag and extract them into a
    # Hash of option names and values.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the options Hash:
    #   key - The String option name.
    #   val - The String option value or true if it is a binary option.
    def parse_image_tag_options(tag)
      tag.split('|')[1..-1].inject({}) do |memo, attr|
        parts = attr.split('=').map { |x| x.strip }
        memo[parts[0]] = (parts.size == 1 ? true : parts[1])
        memo
      end
    end

    # Attempt to process the tag as a file link tag.
    #
    # tag       - The String tag contents (the stuff inside the double
    #             brackets).
    #
    # Returns the String HTML if the tag is a valid file link tag or nil
    #   if it is not.
    def process_file_link_tag(tag)
      parts = tag.split('|')
      return if parts.size.zero?

      name  = parts[0].strip
      path  = parts[1] && parts[1].strip
      path  = if path && file = find_file(path)
        ::File.join @wiki.base_path, file.path
      elsif path =~ %r{^https?://}
        path
      else
        nil
      end

      if name && path && file
        %{<a href="#{::File.join @wiki.base_path, file.path}">#{name}</a>}
      elsif name && path
        %{<a href="#{path}">#{name}</a>}
      else
        nil
      end
    end

    # Attempt to process the tag as a page link tag.
    #
    # tag       - The String tag contents (the stuff inside the double
    #             brackets).
    #
    # Returns the String HTML if the tag is a valid page link tag or nil
    #   if it is not.
    def process_page_link_tag(tag)
      parts = tag.split('|')
      parts.reverse! if @format == :mediawiki

      name, page_name = *parts.compact.map(&:strip)
      cname = @wiki.page_class.cname(page_name || name)

      if name =~ %r{^https?://} && page_name.nil?
        %{<a href="#{name}">#{name}</a>}
      else
        presence    = "absent"
        link_name   = cname
        page, extra = find_page_from_name(cname)
        if page
          link_name = @wiki.page_class.cname(page.name)
          presence  = "present"
        end
        link = ::File.join(@wiki.base_path, page ? page.escaped_url_path : CGI.escape(link_name))

        # //page is invalid
        # strip all duplicate forward slashes using helpers.rb trim_leading_slash
        # //page => /page
        link = trim_leading_slash link

        %{<a class="internal #{presence}" href="#{link}#{extra}">#{name}</a>}
      end
    end


    # Process the special table of contents tag [[_TOC_]]
    #
    # data      - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_toc_tags(data)
      data.gsub!("[[_TOC_]]") do
        @toc.nil? ? '' : @toc
      end
      data
    end

    # Find the given file in the repo.
    #
    # name - The String absolute or relative path of the file.
    #
    # Returns the Gollum::File or nil if none was found.
    def find_file(name, version=@version)
      if name =~ /^\//
        @wiki.file(name[1..-1], version)
      else
        path = @dir == '.' ? name : ::File.join(@dir, name)
        @wiki.file(path, version)
      end
    end

    # Find a page from a given cname.  If the page has an anchor (#) and has
    # no match, strip the anchor and try again.
    #
    # cname - The String canonical page name including path.
    #
    # Returns a Gollum::Page instance if a page is found, or an Array of
    # [Gollum::Page, String extra] if a page without the extra anchor data
    # is found.
    def find_page_from_name(cname)
      slash = cname.rindex('/')

      unless slash.nil?
        name = cname[slash+1..-1]
        path = cname[0..slash]
        page = @wiki.paged(name, path)
      else
        page = @wiki.paged(cname, '/') || @wiki.page(cname)
      end

      if page
        return page
      end
      if pos = cname.index('#')
        [@wiki.page(cname[0...pos]), cname[pos..-1]]
      end
    end

    #########################################################################
    #
    # Gitcode - fetch code from github search path and replace the contents
    #           to a code-block that gets run the next parse.
    #           Acceptable formats:
    #              ```language:local-file.ext```
    #              ```language:/abs/other-file.ext```
    #              ```language:github:gollum/gollum/master/somefile.txt```
    #
    #########################################################################

    def extract_gitcode data
      data.gsub /^[ \t]*``` ?([^:\n\r]+):(?:(github:))?([^`\n\r]+)```/ do
        contents = ''
        # Use empty string if $2 is nil.
        uri = $3 || ''
        # Detect local file.
        if $2.nil?
          if file = self.find_file(uri, @wiki.ref)
            contents = file.raw_data
          else
            # How do we communicate a render error?
            next "File not found: #{Rack::Utils::escape_html(uri)}"
          end
        else
          contents = Gollum::Gitcode.new(uri).contents
        end

        "```#{$1}\n#{contents}\n```\n"
      end
    end

    #########################################################################
    #
    # Code
    #
    #########################################################################

    # Extract all code blocks into the codemap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_code(data)
      data.gsub!(/^([ \t]*)(~~~+) ?([^\r\n]+)?\r?\n(.+?)\r?\n\1(~~~+)[ \t\r]*$/m) do
        m_indent = $1
        m_start  = $2 # ~~~
        m_lang   = $3
        m_code   = $4
        m_end    = $5 # ~~~

        # start and finish tilde fence must be the same length
        return '' if m_start.length != m_end.length

        lang   = m_lang ? m_lang.strip : nil
        id     = Digest::SHA1.hexdigest("#{lang}.#{m_code}")
        cached = check_cache(:code, id)

        # extract lang from { .ruby } or { #stuff .ruby .indent }
        # see http://johnmacfarlane.net/pandoc/README.html#delimited-code-blocks

        if lang
            lang = lang.match(/\.([^}\s]+)/)
            lang = lang[1] unless lang.nil?
        end

        @codemap[id] = cached   ?
          { :output => cached } :
          { :lang => lang, :code => m_code, :indent => m_indent }

        "#{m_indent}#{id}" # print the SHA1 ID with the proper indentation
      end

      data.gsub!(/^([ \t]*)``` ?([^\r\n]+)?\r?\n(.+?)\r?\n\1```[ \t]*\r?$/m) do
        lang   = $2 ? $2.strip : nil
        id     = Digest::SHA1.hexdigest("#{lang}.#{$3}")
        cached = check_cache(:code, id)
        @codemap[id] = cached   ?
          { :output => cached } :
          { :lang => lang, :code => $3, :indent => $1 }
        "#{$1}#{id}" # print the SHA1 ID with the proper indentation
      end
      data
    end

    # Remove the leading space from a code block. Leading space
    # is only removed if every single line in the block has leading
    # whitespace.
    #
    # code      - The code block to remove spaces from
    # regex     - A regex to match whitespace
    def remove_leading_space(code, regex)
      if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ regex }
        code.gsub!(regex) do
          ''
        end
      end
    end

    # Process all code from the codemap and replace the placeholders with the
    # final HTML.
    #
    # data     - The String data (with placeholders).
    # encoding - Encoding Constant or String.
    #
    # Returns the marked up String data.
    def process_code(data, encoding = nil)
      return data if data.nil? || data.size.zero? || @codemap.size.zero?

      blocks    = []
      @codemap.each do |id, spec|
        next if spec[:output] # cached

        code = spec[:code]

        remove_leading_space(code, /^#{spec[:indent]}/m)
        remove_leading_space(code, /^(  |\t)/m)

        blocks << [spec[:lang], code]
      end

      highlighted = []
      blocks.each do |lang, code|
        encoding ||= 'utf-8'
        begin
          # must set startinline to true for php to be highlighted without <?
          # http://pygments.org/docs/lexers/
          hl_code = Pygments.highlight(code, :lexer => lang, :options => {:encoding => encoding.to_s, :startinline => true})
        rescue
          hl_code = code
        end
        highlighted << hl_code
      end

      @codemap.each do |id, spec|
        body = spec[:output] || begin
          if (body = highlighted.shift.to_s).size > 0
            update_cache(:code, id, body)
            body
          else
            "<pre><code>#{CGI.escapeHTML(spec[:code])}</code></pre>"
          end
        end
        data.gsub!(id) do
          body
        end
      end

      data
    end

    #########################################################################
    #
    # Sequence Diagrams
    #
    #########################################################################

    # Extract all sequence diagram blocks into the wsdmap and replace with
    # placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_wsd(data)
      data.gsub(/^\{\{\{\{\{\{ ?(.+?)\r?\n(.+?)\r?\n\}\}\}\}\}\}\r?$/m) do
        id = Digest::SHA1.hexdigest($2)
        @wsdmap[id] = { :style => $1, :code => $2 }
        id
      end
    end

    # Process all diagrams from the wsdmap and replace the placeholders with
    # the final HTML.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_wsd(data)
      @wsdmap.each do |id, spec|
        style = spec[:style]
        code = spec[:code]
        data.gsub!(id) do
          Gollum::WebSequenceDiagram.new(code, style).to_tag
        end
      end
      data
    end

    #########################################################################
    #
    # Metadata
    #
    #########################################################################

    # Extract metadata for data and build metadata table. Metadata
    # is content found between markers, and must
    # be a valid YAML mapping.
    #
    # Because ri and ruby 1.8.7 are awesome, the markers can't
    # be included in this documentation without triggering
    # `Unhandled special: Special: type=17`
    # Please read the source code for the exact markers
    #
    # Returns the String of formatted data with metadata removed.
    def extract_metadata(data)
      @metadata = {}
      data
    end

    # Hook for getting the formatted value of extracted tag data.
    #
    # type - Symbol value identifying what type of data is being extracted.
    # id   - String SHA1 hash of original extracted tag data.
    #
    # Returns the String cached formatted data, or nil.
    def check_cache(type, id)
    end

    # Hook for caching the formatted value of extracted tag data.
    #
    # type - Symbol value identifying what type of data is being extracted.
    # id   - String SHA1 hash of original extracted tag data.
    # data - The String formatted value to be cached.
    #
    # Returns nothing.
    def update_cache(type, id, data)
    end
  end

  MarkupGFM = Markup
end
