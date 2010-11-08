module Precious
  module Views
    class Create < Layout
      include Editable

      attr_reader :page, :name

      def title
        "Create a new page"
      end
      
      def show_title 
        true
      end
      
      def hidden_title
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
