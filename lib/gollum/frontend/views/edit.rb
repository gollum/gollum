module Precious
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def title
        "Edit"
      end
    end
  end
end
