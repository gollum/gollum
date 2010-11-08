module Precious
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def page_name
        @name.gsub('-', ' ')
      end

      def edit_title
        false
      end
      
      def hidden_title
        true
      end

      def title
        "#{@page.title}"
      end
      
    end
  end
end
