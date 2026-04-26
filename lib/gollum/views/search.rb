module Precious
  module Views
    class Search < Layout
      attr_reader :query, :search_terms, :ignore_strings, :ignore_file_types
      include Pagination

      def results
        sorted = @results.sort do |a, b|
          if b.nil?
            b_filename_count = 0
            b_count          = 0
          else
            b_filename_count = b[:filename_count]
            b_count          = b[:count]
          end
          [a[:filename_count], a[:count]] <=> [b_filename_count, b_count]
        end.reverse.slice((@page_num - 1) * @max_count, @max_count)
        sorted.each {|x| x[:href] = page_route(x[:name])}
      end

      def query_string
        query = "&q=%s" % CGI.escape(@query)
        query << "&ignore_strings=%s" % CGI.escape(@ignore_strings) unless @ignore_strings.to_s.empty?
        query << "&ignore_file_types=%s" % CGI.escape(@ignore_file_types) unless @ignore_file_types.to_s.empty?
        query
      end

      def title
        t[:title]
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
