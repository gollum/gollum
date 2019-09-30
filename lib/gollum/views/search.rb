module Precious
  module Views
    class Search < Layout
      attr_reader :results, :query, :search_terms

      def title
        "Search results for " + @query
      end

      def search
        true # View has searchbar
      end

      def has_search_terms
        !@search_terms.empty?
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
