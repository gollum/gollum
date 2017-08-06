module Precious
  module Views
    class FileView < Layout
      include Sprockets::Helpers
      include Precious::Views::SprocketsHelpers
      attr_reader :results, :ref

      def title
        "File view of #{@ref}"
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
