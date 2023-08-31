require 'cgi'

module Precious
  module Views
    class Layout < Mustache
      include Sprockets::Helpers
      include Precious::Views::AppHelpers
      include Precious::Views::LocaleHelpers
      include Precious::Views::SprocketsHelpers
      include Precious::Views::RouteHelpers
      include Precious::Views::OcticonHelpers

      attr_reader :name, :path

      self.extend Precious::Views::TemplateCascade

      # Method should track lib/mustache.rb from Mustache project.
      def partial(name)
        path = self.class.first_path_available(name)
        begin
          File.read(path)
        rescue
          raise if raise_on_context_miss?
          ""
        end
      end
      
      def escaped_name
        CGI.escape(@name)
      end

      def title
        t[:title]
      end

      def has_path
        !@path.nil?
      end

      def base_url
        @base_url
      end

      def custom_path
        @base_url
      end

      def custom_css
        clean_url(custom_path, "custom.css")
      end

      def custom_js
        clean_url(custom_path, "custom.js")
      end

      def mathjax_js
        "#{page_route('gollum/assets/mathjax/tex-mml-chtml.js')}"
      end
      
      def mermaid
        @mermaid
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

      def show_local_time
        @show_local_time ? 'true' : 'false'
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
