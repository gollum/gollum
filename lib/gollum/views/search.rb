module Precious
  module Views
    class Search < Layout
      attr_reader :content, :page, :footer, :results, :query, :search_terms

      def title
        "Search results for " + @query
      end

      def search
        true # View has searchbar
      end

      def has_results
        !@results.empty?
      end

      def no_results
        @results.empty?
      end

    end
  end
end
