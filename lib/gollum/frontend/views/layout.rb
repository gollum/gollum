require 'cgi'

module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      attr_reader :name

      def escaped_name
        CGI.escape(@name)
      end

      def file_name
        CGI.escape(Gollum::Page.cname(@name))
      end

      def title
        "Home"
      end
      
      def base_path
        Precious::App.wiki_options[:base_path]
      end
    end
  end
end
