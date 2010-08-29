module Precious
  module Views
    class Search < Layout
      attr_reader :content, :page, :footer, :query

      def has_results
        !results.empty?
      end

      def results
        ret = []
        @results.each_line do |line|
          result = line.split(":")
          file = result[1]
          count = result[2].to_i
          name = file.split(".")[0]
          ret << {
            :name => name,
            :count => count
          }
        end
        ret
      end
    end
  end
end
