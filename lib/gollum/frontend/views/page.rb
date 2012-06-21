module Precious
  module Views
    class Page < Layout
      include HasPage

      attr_reader :content, :page, :header, :footer
      DATE_FORMAT = "%Y-%m-%d %H:%M:%S"
      DEFAULT_AUTHOR = 'you'

      def title
        @page.url_path.gsub("-", " ")
      end

      def author
        page_versions = @page.versions
        first = page_versions ? page_versions.first : false
        return DEFAULT_AUTHOR unless first
        first.author.name
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
    end
  end
end
