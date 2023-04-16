source 'https://rubygems.org'

gem 'warbler', platforms: :jruby

gem 'asciidoctor'

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
