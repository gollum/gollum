module Precious
  module Views
    class Page < Layout
      include HasPage

      attr_reader :content, :page, :header, :footer, :preview, :historical
      
      VALID_COUNTER_STYLES = ['decimal', 'decimal-leading-zero', 'arabic-indic', 'armenian', 'upper-armenian',
        'lower-armenian', 'bengali', 'cambodian', 'khmer', 'cjk-decimal', 'devanagari', 'georgian', 'gujarati', 'gurmukhi',
        'hebrew', 'kannada', 'lao', 'malayalam', 'mongolian', 'myanmar', 'oriya', 'persian', 'lower-roman', 'upper-roman',
        'tamil', 'telugu', 'thai', 'tibetan', 'lower-alpha', 'lower-latin', 'upper-alpha', 'upper-latin', 'cjk-earthly-branch',
        'cjk-heavenly-stem', 'lower-greek', 'hiragana', 'hiragana-iroha', 'katakana', 'katakana-iroha', 'disc', 'circle', 'square',
        'disclosure-open', 'disclosure-closed'] # https://www.w3.org/TR/css-counter-styles-3/

      DATE_FORMAT    = "%Y-%m-%d %H:%M:%S"
      DEFAULT_AUTHOR = 'you'
      @@to_xml       = { :save_with => Nokogiri::XML::Node::SaveOptions::DEFAULT_XHTML ^ 1, :indent => 0, :encoding => 'UTF-8' }

      def page_header
        title
      end

      def breadcrumb
        path = Pathname.new(@page.url_path).parent
        return '' if path.to_s == '.'
        breadcrumb = [%{<nav aria-label="Breadcrumb"><ol>}]
        path.descend do |crumb|
          element = "#{crumb.basename}"
          next if element == @page.title
          breadcrumb << %{<li class="breadcrumb-item"><a href="#{overview_path}/#{crumb}/">#{CGI.escapeHTML(element.to_s)}</a></li>}
        end
        breadcrumb << %{</ol></nav>}
        breadcrumb.join("\n")
      end

      def content
        content_without_page_header(@content)
      end

      def author
        first = @version ? page.version : page.last_version
        return DEFAULT_AUTHOR unless first
        first.author.name.respond_to?(:force_encoding) ? first.author.name.force_encoding('UTF-8') : first.author.name
      end
      
      def date_full
        first = @version ? page.version : page.last_version
        return Time.now unless first
        first.authored_date
      end

      def date
        date_full.strftime(DATE_FORMAT)
      end
      
      def datetime
        date_full.utc.iso8601
      end
      
      def date_format
        DATE_FORMAT
      end

      def noindex
        @version ? true : false
      end

      def editable
        @editable
      end
      
      def search
        true
      end
      
      def history
        true
      end

      def latest_changes
        true
      end
      
      def overview
        true 
      end
        
      def allow_editing
        @allow_editing
      end

      def allow_uploads
        @allow_uploads
      end

      def has_header
        if @header
          @header.formatted_data.strip.empty? ? false : true
        else
          @header = (@page.header || false)
          !!@header
        end
      end

      def header_content
        has_header && @header.formatted_data
      end

      def header_format
        has_header && @header.format.to_s
      end

      def has_footer
        if @footer
          @footer.formatted_data.strip.empty? ? false : true
        else
          @footer = (@page.footer || false)
          !!@footer
        end
      end

      def footer_content
        has_footer && @footer.formatted_data
      end

      def footer_format
        has_footer && @footer.format.to_s
      end

      def bar_side
        @bar_side.to_s
      end

      def body_side
        @bar_side == :right ? "left" : "right"
      end

      def left_bar
        @bar_side == :left
      end

      def has_sidebar
        if @sidebar
          @sidebar.formatted_data.strip.empty? ? false : true
        else
          @sidebar = (@page.sidebar || false)
          !!@sidebar
        end
      end

      def sidebar_content
        has_sidebar && @sidebar.formatted_data
      end

      def sidebar_format
        has_sidebar && @sidebar.format.to_s
      end

      def has_toc
        !@toc_content.nil?
      end

      def toc_content
        @toc_content
      end

      def mathjax
        @mathjax
      end

      def mathjax_config
        @mathjax_config
      end

      def use_identicon
        @page.wiki.user_icons == 'identicon'
      end

      def navbar?
        @navbar
      end

      def full_url_path
        page_route(@page.escaped_url_path)
      end

      # Access to embedded metadata.
      #
      # Returns Hash.
      def metadata
        @page.metadata
      end   

      # Access to embedded metadata.
      #
      # Examples
      #
      #   {{#rendered_metadata}}{{name}}{{/rendered_metadata}}
      #
      # Returns HTML table.
      def rendered_metadata
        return '' unless page.display_metadata? && !metadata.empty?
        @rendered_metadata ||= table(metadata)
      end

      def header_enum?
        !!metadata['header_enum']
      end

      def header_enum_style
        if header_enum?
          VALID_COUNTER_STYLES.include?(metadata['header_enum']) ? metadata['header_enum'] : 'decimal'
        end
      end

      private

      # Wraps page formatted data to Nokogiri::HTML document.
      #
      def build_document(content)
        Nokogiri::HTML::fragment(%{<div id="gollum-root">} + content.to_s + %{</div>}, 'UTF-8')
      end

      # Finds header node inside Nokogiri::HTML document.
      #
      def find_header_node(doc)
        case @page.format
          when :asciidoc
            doc.css("div#gollum-root > h1:first-child")
          when :pod
            doc.css("div#gollum-root > a.dummyTopAnchor:first-child + h1")
          when :rst
            doc.css("div#gollum-root > div > div > h1:first-child")
          else
            doc.css("div#gollum-root > h1:first-child")
        end
      end

      # Extracts title from page if present.
      #
      def page_header_from_content(content)
        doc   = build_document(content)
        title = find_header_node(doc).inner_text.strip
        title = nil if title.empty?
        title
      end

      # Returns page content without title if it was extracted.
      #
      def content_without_page_header(content)
        doc = build_document(content)
          if @h1_title
            title = find_header_node(doc)
            title.remove unless title.empty?
          end
        # .inner_html will cause href escaping on UTF-8
        doc.css("div#gollum-root").children.to_xml(@@to_xml)
      end

      def table(data)
        return data.to_s if data.empty?
        result = "<table>\n"
        keys = data.respond_to?(:keys) && data.respond_to?(:values) ? data.keys : nil
          if keys
            data = data.values
            result << "<tr>\n"
            keys.each do |heading|
              result << "<th>#{CGI.escapeHTML(heading.to_s)}</th>\n"
            end
            result << "</tr>\n"
          end
        result << "<tr>\n"
          data.each do |value|
            result << "<td>" << (value.respond_to?(:each) ? table(value) : CGI.escapeHTML(value.to_s)) << "</td>\n"
          end
        result << "</tr>\n</table>\n"
      end

      def title
        h1 = @h1_title ? page_header_from_content(@content) : false
        h1 || @page.url_path_title # url_path_title is the metadata title if present, otherwise the filename-based title
      end
    end
  end
end
