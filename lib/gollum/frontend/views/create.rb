module Precious
  module Views
    class Create < Layout
      include Editable

      attr_reader :page

      def title
        "Create a new page"
      end

      def formats
        super(:markdown)
      end
    end
  end
end
