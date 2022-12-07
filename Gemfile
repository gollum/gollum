source 'https://rubygems.org'

gem 'warbler', platforms: :jruby

# FIXME:
#
# There's an issue in 1.12.5 that causes XHTML elements to be generated badly,
# causing Gollum's test suite to fail.[1] The issue has been fixed upstream,
# but we're still waiting for a new Nokogiri point release.
#
# However, 1.12.5 is a security patch, so we don't want end users to use an
# older version of Nokogiri. But this is safe to do in our CI environment.
#
# Once there's a new Nokogiri release, we can remove this dependency and JRuby
# CI should pass normally again.
#
# Note that Nokogiri 1.11+ does not support Ruby v2.4.x anymore. So to make our
# current CI workflows pass, we should only try to install this version of
# Nokogiri for newer Ruby versions.

group :test do
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
end

gemspec

gem 'rake', '~> 13.0'
