module Precious
  module Views
    class Page < Layout
      include HasPage

      attr_reader :content, :page, :header, :footer
      DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
      DEFAULT_AUTHOR = 'you'

      def title
        h1 = @h1_title ? page_header_from_content(@content) : false
        h1 || @page.url_path_title
      end

      def page_header
        page_header_from_content(@content) || title
      end

      def content
        content_without_page_header(@content)
      end

      def author
        page_versions = @page.versions
        first = page_versions ? page_versions.first : false
        return DEFAULT_AUTHOR unless first
        first.author.name.respond_to?(:force_encoding) ? first.author.name.force_encoding('UTF-8') : first.author.name
      end

      def date
        page_versions = @page.versions
        first = page_versions ? page_versions.first : false
        return Time.now.strftime(DATE_FORMAT) unless first
        first.authored_date.strftime(DATE_FORMAT)
      end

      def editable
        @editable
      end

      def has_header
        @header = (@page.header || false) if @header.nil?
        !!@header
      end

      def header_content
        has_header && @header.formatted_data
      end

      def header_format
        has_header && @header.format.to_s
      end

      def has_footer
        @footer = (@page.footer || false) if @footer.nil?
        !!@footer
      end

      def footer_content
        has_footer && @footer.formatted_data
      end

      def footer_format
        has_footer && @footer.format.to_s
      end

      def has_sidebar
        @sidebar = (@page.sidebar || false) if @sidebar.nil?
        !!@sidebar
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

      def use_identicon
        @page.wiki.user_icons == 'identicon'
      end

      # Access to embedded metadata.
      #
      # Examples
      #
      #   {{#metadata}}{{name}}{{/metadata}}
      #
      # Returns Hash.
      def metadata
        @page.metadata
      end

      private

      # Wraps page formatted data to Nokogiri::HTML document.
      #
      def build_document(content)
        Nokogiri::HTML(%{<div id="gollum-root">} + content + %{</div>})
      end

      # Finds header node inside Nokogiri::HTML document.
      #
      def find_header_node(doc)
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
      end

      # Extracts title from page if present.
      #
      def page_header_from_content(content)
        doc = build_document(content)
        title = find_header_node(doc)
        Sanitize.clean(title.to_html).strip unless title.empty?
      end

      # Returns page content without title if it was extracted.
      #
      def content_without_page_header(content)
        doc = build_document(content)
        title = find_header_node(doc)
        title.remove unless title.empty?
        doc.css("div#gollum-root").inner_html
      end
    end
  end
end
