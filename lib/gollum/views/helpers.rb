require 'json'

module Precious
  module Views
    
    module AppHelpers
      def extract_page_dir(path)
        return path if @page_dir.to_s.empty?
        @extract_path ||= "#{Pathname.new(@page_dir).cleanpath.to_s}/"
        path.start_with?(@extract_path) ? path[@extract_path.length..-1] : path
      end
    end

    module RouteHelpers
      ROUTES = {
        'gollum' => {
          assets: 'assets',
          last_commit_info: 'last_commit_info',
          latest_changes: 'latest_changes',
          upload_file: 'upload_file',
          create: 'create',
          delete: 'delete',
          edit: 'edit',
          overview: 'overview',
          history: 'history',
          rename: 'rename',
          revert: 'revert',
          preview: 'preview',
          compare: 'compare',
          search: 'search'
        }
      }

      def self.parse_routes(routes, prefix = '')
        routes.each do |name, path|
          if path.respond_to?(:keys)
            self.parse_routes(path, "#{prefix}/#{name}")
          else
            route_path = "#{prefix}/#{path}"
            @@route_methods[name.to_s] = route_path
            define_method :"#{name.to_s}_path" do
              "#{base_url}/#{route_path}".gsub(/\/{2,}/, '/') # remove double slashes
            end
          end
        end
      end

      def self.included(base)
        @@route_methods = {}
        self.parse_routes(ROUTES)
        define_method :routes_to_json do
          @@route_methods.to_json
        end
      end

      def page_route(page)
        "#{base_url}/#{page}".gsub(/\/{2,}/, '/')
      end
    end

    module OcticonHelpers
      def self.included(base)
        
        def rocticon(symbol, parameters = {})
          Octicons::Octicon.new(symbol, parameters).to_svg
        end
        
        def octicon
          lambda do |args|
            symbol, height, width = args.split(' ')
            parameters = {}
            parameters[:height] = height if height
            parameters[:width]  = width if width
            Octicons::Octicon.new(symbol, parameters).to_svg
          end
        end
      end
    end


    module SprocketsHelpers
      def self.included(base)

        def sprockets_stylesheet_tag
          lambda do |args|
            args = args.split(' ')
            name = args[0]
            options = {:media => :all}
            options[:media] = :print if args[1] == 'print'
            send(:stylesheet_tag, name, options)
          end
        end

        def sprockets_javascript_tag
          lambda do |name|
            send(:javascript_tag, name)
          end
        end

        def sprockets_image_path
          lambda do |args|
            send(:image_path, name)
          end
        end
      end
    end
  end
end
