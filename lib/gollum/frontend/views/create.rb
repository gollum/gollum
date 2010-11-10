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

      def page_name
        @name.gsub('-', ' ')
      end

      def formats
        super(:markdown)
      end
    end
  end
end
