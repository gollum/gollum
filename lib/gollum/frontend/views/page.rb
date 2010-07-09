module Precious
  module Views
    class Page < Layout
      attr_reader :content

      def human_name
        @name.gsub(/-/, ' ')
      end

      def title
        "A Page"
      end
    end
  end
end
