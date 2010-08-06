module Precious
  module Views
    class Edit < Layout
      include Editable

      attr_reader :page, :content

      def title
        "Editing #{@page.title}"
      end
    end
  end
end
