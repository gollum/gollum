module Precious
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def title
        @page.path
      end

      def page_name
        @name.gsub('-', ' ')
      end

      def header
        if @header.nil?
          if page = @page.header
            @header = page.raw_data
          else
            @header = false
          end
        end
        @header
      end

      def footer
        if @footer.nil?
          if page = @page.footer
            @footer = page.raw_data
          else
            @footer = false
          end
        end
        @footer
      end

      def sidebar
        if @sidebar.nil?
          if page = @page.sidebar
            @sidebar = page.raw_data
          else
            @sidebar = false
          end
        end
        @sidebar
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
    end
  end
end
