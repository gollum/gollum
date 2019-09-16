require 'cgi'

module Precious
  module Views
    class Layout < Mustache
      include Rack::Utils
      include Sprockets::Helpers
      include Precious::Views::AppHelpers
      include Precious::Views::SprocketsHelpers
      include Precious::Views::RouteHelpers
      include Precious::Views::OcticonHelpers
      
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

      def base_url
        @base_url
      end

      def custom_path
        "#{@base_url}"
      end

      def css # custom css
        @css
      end

      def js # custom js
        @js
      end
      
      def critic_markup
        @critic_markup
      end
      
      def per_page_uploads
        @per_page_uploads
      end

      # Navigation bar
      def search
        false
      end
      
      def history
        false
      end
      
      def overview
        false
      end
      
      def latest_changes
        false
      end
      
    end
  end
end
