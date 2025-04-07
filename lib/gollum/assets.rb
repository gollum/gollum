require 'octicons'

module Precious
  module Assets
    MANIFEST = %w(app.js editor.js gollum.mermaid.js gollum.katex.js app.css criticmarkup.css fileview.css ie7.css print.css katex/dist/katex.css *.png *.jpg *.svg *.eot *.ttf)
    ASSET_URL = 'gollum/assets'

    def self.sprockets(dir = File.dirname(File.expand_path(__FILE__)))
      env = Sprockets::Environment.new

      env.append_path ENV.fetch('GOLLUM_DEV_ASSETS', ::File.join(dir, '../../node_modules'))

      env.append_path ::File.join(dir, 'public/gollum/javascript')
      env.append_path ::File.join(dir, 'public/gollum/stylesheets/')

      env.append_path ::File.join(dir, 'public/gollum/images')
      env.append_path ::File.join(dir, 'public/gollum/fonts')

      env.js_compressor  = ::Precious::Assets::JS_COMPRESSOR if defined?(::Precious::Assets::JS_COMPRESSOR)
      env.css_compressor = :sassc

      options = {
        sass_config: {
          quiet_deps: true
        }
      }

      env.register_transformer 'text/sass', 'text/css', Sprockets::SasscProcessor.new(options)
      env.register_transformer 'text/scss', 'text/css', Sprockets::ScsscProcessor.new(options)

      env.context_class.class_eval do
        def base_url
          self.class.class_variable_get(:@@base_url)
        end
        include ::Octicons
        include ::Precious::Views::RouteHelpers
        include ::Precious::Views::OcticonHelpers
      end
      env
    end
  end
end

module Sprockets
  class SasscProcessor
    module Functions
      def rocticon_css(name, parameters = {})
        symbol = name.value.to_sym
        octicon = ::Octicons::Octicon.new(symbol, parameters.merge({xmlns: 'http://www.w3.org/2000/svg'}))
        [:width, :height].each {|option| octicon.options.delete(option)}
        ::SassC::Script::Value::String.new(octicon.to_svg)
      end
    end
  end
end
