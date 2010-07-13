module Precious
  module Views
    class Edit < Layout
      attr_reader :page, :content

      def title
        "Edit"
      end
    end
  end
end
