module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      def title
        "Home"
      end
    end
  end
end
