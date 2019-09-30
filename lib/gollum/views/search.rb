module Precious
  module Views
    class Search < Layout
      attr_reader :query, :search_terms

      def title
        "Search results for " + @query
      end

      def sorted_results
        sorted = @results.sort do |a, b|
          if b.nil?
            b_filename_count = 0
            b_count          = 0
          else
            b_filename_count = b[:filename_count]
            b_count          = b[:count]
          end
          [a[:filename_count], a[:count]] <=> [b_filename_count, b_count]
        end
        sorted.reverse!
        sorted = sorted.each_slice(5).to_a # Paginate: groups of five
        sorted = sorted.each_with_index.map do |result, index|
          {:index => index.to_i + 1, :results => result}
        end
        sorted
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
