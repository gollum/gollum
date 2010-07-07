module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      attr_reader :name

      def title
        "Home"
      end
    end
  end
end
