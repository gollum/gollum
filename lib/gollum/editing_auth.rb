module Precious
  class EditingAuth  < Sinatra::Base
    def initialize(app)
      @app = app
    end

    def call(env)
      @env = env
      # Blocks all potentially editable pages. Use EditingAuth::whitelist_pages to unblock pages.
      unless (env["REQUEST_METHOD"] == "GET") || App::settings.wiki_options[:allow_editing]
        return block unless excluded_page?
      end
      @app.call(env)
    end

    def block
      [403, {'Content-Type' => 'text/html', 'Content-Length' => '9'}, ['Forbidden']]
    end

    def excluded_page?
      return false if env["REQUEST_PATH"].nil?
      whitelist_pages.any? do |whitelisted_page|
        env["REQUEST_PATH"].include? whitelisted_page
      end
    end

  private
    # List pages paths as str that you want to whitelist.
    # Pages will be compared with env["REQUEST_PATH"] using String::include? method.
    def whitelist_pages
      return ["/compare/"]
    end
  end
end