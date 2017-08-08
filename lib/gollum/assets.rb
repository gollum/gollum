module Precious
  module Assets
    MANIFEST = %w(app.js app.css fileview.css ie7.css print.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)
    ASSET_URL = 'assets'
    
    def self.sprockets(dir = File.dirname(File.expand_path(__FILE__)))
      env = Sprockets::Environment.new
      env.append_path ::File.join(dir, 'public/gollum/stylesheets/')
      env.append_path ::File.join(dir, 'public/gollum/javascript')
      env.append_path ::File.join(dir, 'public/gollum/images')
      env.append_path ::File.join(dir, 'public/gollum/fonts')

      env.js_compressor  = :uglify
      env.css_compressor = :scss
      env
    end
  end
end