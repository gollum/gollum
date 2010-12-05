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
        
      def format
        @format = (@page.format || false) if @format.nil?
        @format.to_s.downcase
      end
    
      def has_footer 
        @footer = (@page.footer || false) if @footer.nil?
        !!@footer
      end
        
      def has_sidebar
        @sidebar = (@page.sidebar || false) if @sidebar.nil?
        !!@sidebar
      end

      def title
        "#{@page.title}"
      end
      
    end
  end
end
