module Precious
  module Views
    class Search < Layout
      attr_reader :content, :page, :footer, :results, :query

      def has_results
        !@results.empty?
      end

    end
  end
end
