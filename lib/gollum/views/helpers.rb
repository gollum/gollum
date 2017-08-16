require 'yaml'

module Precious
  module Views

    module RouteHelpers
      ROUTES = {
        'gollum' => {
          :last_commit_info => 'last-commit-info',
          :latest_changes => 'latest_changes',
          :upload_file => 'uploadFile',
          :create => 'create',
          :delete => 'delete',
          :edit => 'edit',
          :fileview => 'fileview',
          :pages => 'pages',
          :history => 'history',
          :rename => 'rename',
          :preview => 'preview',
          :compare => 'compare',
          :search => 'search'
        }
      }

      def self.parse_routes(routes, prefix = '')
        routes.each do |name, path|
          if path.respond_to?(:keys) then
            self.parse_routes(path, "#{prefix}/#{name}")
          else
            define_method :"#{name.to_s}_path" do
              "#{base_url}/#{prefix}/#{path}".gsub(/\/{2,}/, '/')
            end
          end
        end
      end

      def self.included(base)
        self.parse_routes(ROUTES)
      end
    end

    module SprocketsHelpers
      def self.included(base)

        def helper_proc_with_options(method)
          Proc.new do |args|
            args = args.split(' ')
            if args.size > 1 then
              options = args[1..-1].join(' ')
              options = YAML.safe_load("---\n#{options}\n", [Symbol])
            end
            options = options.respond_to?(:to_h) ? options.to_h : {}
            options = options.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            send(method, args[0], options)
          end  
        end

        ['stylesheet_path','javascript_path', 'image_path'].each do |method|
          define_method :"#{method}_mustache" do
            Proc.new {|args| send(method.to_sym, args)}
          end
        end

        ['stylesheet_tag','javascript_tag'].each do |method|
          define_method :"#{method}_mustache" do
            helper_proc_with_options(method.to_sym)
          end
        end
      end
    end
  end
end