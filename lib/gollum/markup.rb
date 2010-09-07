require 'digest/sha1'

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
      @data    = page.raw_data
      @version = page.version.id
      @dir     = ::File.dirname(page.path)
      @tagmap  = {}
      @codemap = {}
      @texmap  = {}
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # Returns the formatted String content.
    def render
      data = extract_tex(@data)
      data = extract_code(data)
      data = extract_tags(data)
      data = extract_dynamic_tags(data)
      begin
        data = GitHub::Markup.render(@name, data)
        if data.nil?
          raise "There was an error converting #{@name} to HTML."
        end
      rescue Object => e
        data = %{<p class="gollum-error">#{e.message}</p>}
      end
      data = process_tags(data)
      data = process_dynamic_tags(data)
      data = process_code(data)
      data = Sanitize.clean(data, SANITIZATION_OPTIONS)
      data = process_tex(data)
      data = data.gsub(/<p><\/p>/, '')
      data
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
        id = Digest::SHA1.hexdigest($1)
        @texmap[id] = [:block, $1]
        id
      end.gsub(/\\\(\s*(.*?)\s*\\\)/m) do
        id = Digest::SHA1.hexdigest($1)
        @texmap[id] = [:inline, $1]
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
      data.gsub(/(.?)\[\[(.+?)\]\]([^\[]?)/m) do
        if $1 == "'" && $3 != "'"
          "[[#{$2}]]#{$3}"
        elsif $2.include?('][')
          $&
        else
          id = Digest::SHA1.hexdigest($2)
          @tagmap[id] = $2
          "#{$1}#{id}#{$3}"
        end
      end
    end

    # Process all tags from the tagmap and replace the placeholders with the
    # final markup.
    #
    # data - The String data (with placeholders).
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
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML version of the tag.
    def process_tag(tag)
      if html = process_image_tag(tag)
        return html
      elsif html = process_file_link_tag(tag)
        return html
      else
        return process_page_link_tag(tag)
      end
    end

    # Extract all dynamic tags into the tagmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_dynamic_tags(data)
      data.gsub(/(.?)\{\{(.+?)\}\}([^\[]?)/m) do
        if $1 == "'" && $3 != "'"
          "{{#{$2}}}#{$3}"
        elsif $2.include?('}{')
          $&
        else
          id = Digest::SHA1.hexdigest($2)
          @tagmap[id] = $2
          "#{$1}#{id}#{$3}"
        end
      end
    end

    # Process all dynamic tags from the tagmap and replace the placeholders
    # with the final markup.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_dynamic_tags(data)
      @tagmap.each do |id, tag|
        data.gsub!(id, process_dynamic_tag(tag))
      end
      data
    end

    # Process a single dynamic tag into its final HTML form.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML version of the tag.
    def process_dynamic_tag(tag)
      if html = process_dynamic_pages_tag(tag)
        return html
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
      name  = parts[0].strip
      path  = if file = find_file(name)
        ::File.join @wiki.base_path, file.path
      elsif name =~ /^https?:\/\/.+(jpg|png|gif|svg|bmp)$/
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
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid file link tag or nil
    #   if it is not.
    def process_file_link_tag(tag)
      parts = tag.split('|')
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
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid page link tag or nil
    #   if it is not.
    def process_page_link_tag(tag)
      parts = tag.split('|')
      name  = parts[0].strip
      cname = Page.cname((parts[1] || parts[0]).strip)
      if name =~ %r{^https?://} && parts[1].nil?
        %{<a href="#{name}">#{name}</a>}
      else
        if page = @wiki.page(cname)
          link = ::File.join(@wiki.base_path, Page.cname(page.name))
          presence = "present"
        else
          link = ::File.join(@wiki.base_path, cname)
          presence = "absent"
        end
        %{<a class="internal #{presence}" href="#{link}">#{name}</a>}
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

    # Attempt to process the tag as a pages list tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML of Pages as an unordered list, with page links.
    def process_dynamic_pages_tag(tag)
      if tag == 'pages'
	pages = @wiki.pages
	pages_li_html = ''
	if pages.size > 0:
	  pages_li_html = pages.map { |p| %{<li>#{process_page_link_tag(p.name)}</li>} }
        end
        %{<ul id="pages">#{pages_li_html}</ul>}
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
      data.gsub(/^``` ?(.+?)\r?\n(.+?)\r?\n```\r?$/m) do
        id = Digest::SHA1.hexdigest($2)
        @codemap[id] = { :lang => $1, :code => $2 }
        id
      end
    end

    # Process all code from the codemap and replace the placeholders with the
    # final HTML.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_code(data)
      @codemap.each do |id, spec|
        lang = spec[:lang]
        code = spec[:code]
        if code.lines.all? { |line| line =~ /\A\r?\n\Z/ || line =~ /^(  |\t)/ }
          code.gsub!(/^(  |\t)/m, '')
        end
        data.gsub!(id, Gollum::Albino.new(code, lang).colorize)
      end
      data
    end
  end
end
