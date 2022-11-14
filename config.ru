=begin
You should use this file, if you wish to:
- launch Gollum as a Rack app,
- alter certain startup behaviour of Gollum.

For more information and examples:
- https://github.com/gollum/gollum/wiki/Gollum-via-Rack
- https://github.com/gollum/gollum#config-file

=end

# enter your Ruby code here ...
  # Use Redis store for caching.
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
  
  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
