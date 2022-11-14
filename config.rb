=begin
This file can be used to (e.g.):
- alter certain inner parts of Gollum,
- extend it with your stuff.

It is especially useful for customizing supported formats/markups. For more information and examples:
- https://github.com/gollum/gollum#config-file

=end

# enter your Ruby code here ...
  # Use Redis store for caching.
  config.cache_store = :redis_cache_store, { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
  
  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
