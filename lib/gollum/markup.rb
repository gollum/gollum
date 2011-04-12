require 'digest/sha1'
require 'cgi'

module Gollum
  class Markup
    # Initialize a new Markup object.
    #
    # page - The Gollum::Page.
    #
    # Returns a new Gollum::Markup object, ready for rendering.
    def initialize(page)
      @wiki    = page.wiki
      @name    = page.filename
      @data    = page.text_data
      @version = page.version.id
      @format  = page.format
      @dir     = ::File.dirname(page.path)
      @tagmap  = {}
      @codemap = {}
      @texmap  = {}
      @premap  = {}
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # no_follow - Boolean that determines if rel="nofollow" is added to all
    #             <a> tags.
    #
    # Returns the formatted String content.
    def render(no_follow = false)
      sanitize = no_follow ?
        @wiki.history_sanitizer :
        @wiki.sanitizer

      data = extract_tex(@data.dup)
      data = extract_code(data)
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
      data = process_code(data)
      if sanitize || block_given?
        doc  = Nokogiri::HTML::DocumentFragment.parse(data)
        doc  = sanitize.clean_node!(doc) if sanitize
        yield doc if block_given?
        data = doc_to_html(doc)
      end
      data = process_tex(data)
      data.gsub!(/<p><\/p>/, '')
      data
    end

    def doc_to_html(doc)
      doc.to_xhtml(:save_with => Nokogiri::XML::Node::SaveOptions::AS_XHTML)
    end

    #########################################################################
    #
    # TeX
    #
    #########################################################################

    # Extract all TeX into the texmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_tex(data)
      data.gsub(/\\\[\s*(.*?)\s*\\\]/m) do
        tag = CGI.escapeHTML($1)
        id  = Digest::SHA1.hexdigest(tag)
        @texmap[id] = [:block, tag]
        id
      end.gsub(/\\\(\s*(.*?)\s*\\\)/m) do
        tag = CGI.escapeHTML($1)
        id  = Digest::SHA1.hexdigest(tag)
        @texmap[id] = [:inline, tag]
        id
      end
    end

    # Process all TeX from the texmap and replace the placeholders with the
    # final markup.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_tex(data)
      @texmap.each do |id, spec|
        type, tex = *spec
        out =
        case type
          when :block
            %{<script type="math/tex; mode=display">#{tex}</script>}
          when :inline
            %{<script type="math/tex">#{tex}</script>}
        end
        data.gsub!(id, out)
      end
      data
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
        data.gsub!(id, process_tag(tag))
      end
      data
    end

    # Process a single tag into its final HTML form.
    #
    # tag       - The String tag contents (the stuff inside the double
    #             brackets).
    #
    # Returns the String HTML version of the tag.
    def process_tag(tag)
      if html = process_image_tag(tag)
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
        link = ::File.join(@wiki.base_path, CGI.escape(link_name))
        %{<a class="internal #{presence}" href="#{link}#{extra}">#{name}</a>}
      end
    end

    # Find the given file in the repo.
    #
    # name - The String absolute or relative path of the file.
    #
    # Returns the Gollum::File or nil if none was found.
    def find_file(name)
      if name =~ /^\//
        @wiki.file(name[1..-1], @version)
      else
        path = @dir == '.' ? name : ::File.join(@dir, name)
        @wiki.file(path, @version)
      end
    end

    # Find a page from a given cname.  If the page has an anchor (#) and has
    # no match, strip the anchor and try again.
    #
    # cname - The String canonical page name.
    #
    # Returns a Gollum::Page instance if a page is found, or an Array of
    # [Gollum::Page, String extra] if a page without the extra anchor data
    # is found.
    def find_page_from_name(cname)
      if page = @wiki.page(cname)
        return page
      end
      if pos = cname.index('#')
        [@wiki.page(cname[0...pos]), cname[pos..-1]]
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
      data.gsub!(/^``` ?([^\r\n]+)?\r?\n(.+?)\r?\n```\r?$/m) do
        id     = Digest::SHA1.hexdigest($2)
        cached = check_cache(:code, id)
        @codemap[id] = cached   ?
          { :output => cached } :
          { :lang => $1, :code => $2 }
        id
      end
      data
    end

    # Process all code from the codemap and replace the placeholders with the
    # final HTML.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_code(data)
      return data if data.nil? || data.size.zero? || @codemap.size.zero?

      blocks    = []
      @codemap.each do |id, spec|
        next if spec[:output] # cached

        code = spec[:code]
        if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(  |\t)/ }
          code.gsub!(/^(  |\t)/m, '')
        end

        blocks << [spec[:lang], code]
      end

      highlighted = begin
        blocks.size.zero? ? [] : Gollum::Albino.colorize(blocks)
      rescue ::Albino::ShellArgumentError, ::Albino::TimeoutExceeded,
               ::Albino::MaximumOutputExceeded
        []
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
        data.gsub!(id, body)
      end

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
end
