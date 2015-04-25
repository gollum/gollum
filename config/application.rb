require File.expand_path('../boot',__FILE__)
require 'rails/all'

module gollum
	class Application < Rails::Application
		config.action_dispatch.default_headers = {'X-Frame-Options' => 'ALLOWALL' }
	end
end
