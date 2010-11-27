module Precious
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def page_name
        @name.gsub('-', ' ')
      end

      def is_create_page
        false
      end
      
      def is_edit_page
        true
      end

      def title
        "#{@page.title}"
      end
      
    end
  end
end
