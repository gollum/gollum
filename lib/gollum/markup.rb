require 'digest/sha1'

module Gollum
  class Markup
    # Initialize a new Markup object.
    #
    # page - The Gollum::Page.
    #
    # Returns a new Gollum::Markup object, ready for rendering.
    def initialize(page)
      @wiki = page.wiki
      @name = page.name
      @data = page.raw_data
      @version = page.version.id
      @dir = ::File.dirname(page.path)
      @tagmap = {}
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # Returns the formatted String content.
    def render
      data = extract_tags(@data)
      data = GitHub::Markup.render(@name, data) rescue ''
      data = process_tags(data)
    end

    # Extract all tags into the tagmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_tags(data)
      data.gsub(/\[\[(.+?)\]\]/) do
        id = Digest::SHA1.hexdigest($1)
        @tagmap[id] = $1
        id
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
        data.sub!(id, process_tag(tag))
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

    # Attempt to process the tag as an image tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid image tag or nil
    #   if it is not.
    def process_image_tag(tag)
      parts = tag.split('|')
      name = parts[0].strip

      if file = find_file(name)
        opts = parse_image_tag_options(tag)

        containered = false

        classes = [] # applied to whatever the outermost container is
        attrs = []   # applied to the image
        styles = []  # applied to the image

        align = opts['align']
        if opts['float']
          containered = true
          align ||= 'left'
          if %w{left right}.include?(align)
            classes << "float-#{align};"
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
            styles << "max-width: #{width};"
          end
        end

        if height = opts['height']
          if height =~ /^\d+(\.\d+)?(em|px)$/
            styles << "max-height: #{height};"
          end
        end

        if alt = opts['alt']
          attrs << %{alt="#{alt}"}
        end

        attr_string = attrs.size > 0 ? attrs.join(' ') + ' ' : ''

        style_string = ''
        unless styles.empty?
          style_string = %{ style="#{styles.join(' ')}"}
        end

        if opts['frame'] || containered
          classes << 'frame' if opts['frame']
          %{<div class="#{classes.join(' ')}">} +
          %{<div>} +
          %{<img src="/#{file.path}"#{style_string} #{attr_string}/>} +
          (alt ? %{<p>#{alt}</p>} : '') +
          %{</div>} +
          %{</div>}
        else
          %{<img src="/#{file.path}"#{style_string} #{attr_string}/>}
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
      name = parts[0].strip
      path = parts[1] && parts[1].strip

      if name && path && file = find_file(path)
        %{<a href="/#{file.path}">#{name}</a>}
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
      name = parts[0].strip
      cname = Gollum::canonical_name((parts[1] || parts[0]).strip)
      %{<a href="#{cname}">#{name}</a>}
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
        path = ::File.join(@dir, name)
        @wiki.file(path, @version)
      end
    end
  end
end