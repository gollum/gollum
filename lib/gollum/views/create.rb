module Precious
  module Views
    class Create < Layout
      include Editable

      attr_reader :page, :name

      def title
        "Create a new page"
      end

      def is_create_page
        true
      end

      def is_edit_page
        false
      end

      def allow_uploads
        @allow_uploads
      end

      def upload_dest
        @upload_dest
      end

      def format
        @format = (@page.format || false) if @format.nil? && @page
        @format.to_s.downcase
      end

      def has_footer
        @footer = (@page.footer || false) if @footer.nil? && @page
        !!@footer
      end

      def has_header
        @header = (@page.header || false) if @header.nil? && @page
        !!@header
      end

      def has_sidebar
        @sidebar = (@page.sidebar || false) if @sidebar.nil? && @page
        !!@sidebar
      end

      def page_name
        @name.gsub('-', ' ')
      end

      def formats
        super(:markdown)
      end

      def default_markup
        Precious::App.settings.default_markup
      end
    end
  end
end
