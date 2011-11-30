module Precious
  module Views
    class Pages2 < Layout
      attr_reader :results, :ref

      def title
        "All pages in #{@ref}"
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
