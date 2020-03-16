source 'https://rubygems.org'

if RUBY_PLATFORM == 'java'
  gem 'warbler'
  gem 'gollum-rjgit_adapter'
else
  gem 'gollum-rugged_adapter'
end

gem 'gollum-lib', :git => 'https://github.com/gollum/gollum-lib.git', :branch => 'gollum-lib-5.x' # For development purposes
gem 'therubyrhino', :platforms => :jruby
gemspec
gem "rake", ">= 12.3.3"

