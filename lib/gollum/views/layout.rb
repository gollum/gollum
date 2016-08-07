require 'cgi'

module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      alias_method :h, :escape_html

      attr_reader :name, :path

      def escaped_name
        CGI.escape(@name)
      end

      def title
        "Home"
      end

      def has_path
        !@path.nil?
      end

      def page_dir
        @page_dir
      end

      def base_url
        @base_url
      end

      def custom_path
        "#{@base_url}#{@page_dir.empty? ? '' : '/'}#{@page_dir}"
      end

      def css # custom css
        @css
      end

      def js # custom js
        @js
      end

    end
  end
end
