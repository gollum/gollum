# HEAD

* Major Enhancements
  * Optimize page write/update/delete to use Grit::Index::read_tree instead
    of manually recreating entire index contents.
  * Added --irb option for the gollum command.
  * Update working dir (if present) when edited via the API (#6)
* Minor Enhancements
  * Support a `:gollum_path` Sinatra setting for `Precious::App`
  * Add Wiki#size to efficiently count pages without loading them.
  * Add the correct content type when serving files from the frontend.
* Bug Fixes
  * Increase minimum Sanitize version requirement to 1.1.0.
    1.0.x versions of Sanitize require Hpricot instead of Nokogiri
    and have bugs that may allow non-whitelisted HTML to sneak
    through.
  * Introduce Ruby 1.9 compatibility fixes.
  * Commit hashes are normalized so that missing author data is replaced with
    anonymous info.
  * Prevent `Gollum::Wiki#write_page` from clobbering existing pages.
  * Handle duplicate page errors in frontend.

# 1.0.1 / 2010-08-12

* Bug Fixes
  * Force Grit dep to 2.1 or higher.

# 1.0.0 / 2010-08-12

* Open Source Birthday!