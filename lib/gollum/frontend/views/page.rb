module Precious
  module Views
    class Page < Layout
      attr_reader :content

      def title
        "A Page"
      end
    end
  end
end
