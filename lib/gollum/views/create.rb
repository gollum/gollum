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

      def format
        @format ||= find_format.to_s.downcase
      end

      def page_name
        @name
      end

      def formats
        super(find_format)
      end

      def default_markup
        Precious::App.settings.default_markup
      end

      #QND - sets default template page if specified
      def content
        @template_page
      end
      
      private
      
      def find_format
        @found_format ||= (Gollum::Page.format_for("#{@name}#{@ext}") || default_markup)
      end
    end
  end
end
