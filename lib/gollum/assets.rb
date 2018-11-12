module Precious
  module Assets
    MANIFEST = %w(app.js app.css criticmarkup.css fileview.css ie7.css print.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)
    ASSET_URL = 'gollum/assets'
    
    def self.sprockets(dir = File.dirname(File.expand_path(__FILE__)))
      env = Sprockets::Environment.new
      env.append_path ::File.join(dir, 'public/gollum/stylesheets/')
      env.append_path ::File.join(dir, 'public/gollum/javascript')
      env.append_path ::File.join(dir, 'public/gollum/images')
      env.append_path ::File.join(dir, 'public/gollum/fonts')

      env.js_compressor  = :uglify
      env.css_compressor = :scss

      env.context_class.class_eval do
        def base_url
          self.class.class_variable_get(:@@base_url)
        end
        include ::Precious::Views::RouteHelpers
      end
      env
    end
  end
end