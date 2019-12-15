module Precious
  module Views
    class Search < Layout
      attr_reader :query, :search_terms
      include Pagination

      def results
        @results.sort do |a, b|
          if b.nil?
            b_filename_count = 0
            b_count          = 0
          else
            b_filename_count = b[:filename_count]
            b_count          = b[:count]
          end
          [a[:filename_count], a[:count]] <=> [b_filename_count, b_count]
        end.reverse.slice((@page_num - 1) * @max_count, @max_count)
      end

      def query_string
        "&q=#{@query}"
      end

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
