module Precious
  module Views
    class Page < Layout
      attr_reader :content, :page, :footer

      def title
        @page.title
      end

      def format
        @page.format.to_s
      end

      def author
        @page.version.author.name
      end

      def date
        @page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S")
      end
      
      def editable
        @editable
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
    end
  end
end
