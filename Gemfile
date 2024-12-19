source 'https://rubygems.org'

gem 'warbler', git: 'https://github.com/jruby/warbler' if RUBY_PLATFORM == 'java'

# FIXME: There is an upstream JRuby 9.4.9.0 issue with `psych` and the latest
# version of `jar-dependencies`. The issue will be resolved with the release of
# 9.4.10.0. Then, we can remove this `jar-dependencies` dependency lock.
#
# Gollum end users using JRuby may need to add this lock to their own project
# Gemfiles, too, unfortunately. :-(
#
# For more information, see: https://github.com/jruby/jruby/issues/8488
#
gem 'jar-dependencies', '< 0.5'

group :test do
  gem 'selenium-webdriver', require: false
  gem 'capybara', require: false
end

group :development do
  unless RUBY_PLATFORM.match(/linux-musl$/)
    gem 'sassc',  '~> 2.4'
    gem 'sassc-embedded', '~> 1.54'
  end
end

gemspec

gem 'rake', '~> 13.0'
