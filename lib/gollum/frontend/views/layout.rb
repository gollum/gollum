require 'cgi'

module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      attr_reader :name

      def escaped_name
        if @path
          CGI.escape("#{@path}/#{@name}")
        else
          CGI.escape(@name)
        end
      end

      def title
        "Home"
      end
    end
  end
end
