require 'rubygems'
require 'gollum/app'

use Rack::Session::Cookie, :key => 'rack.session',
  :path => '/',
  :secret => 'your_secret'

ENV['user_file'] = './users.txt'
ENV['password'] = 'rejuvenation'
gollum_path = File.expand_path(File.dirname('./wiki')) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {
  :universal_toc => false,
  :allow_uploads => true
})
run Precious::App
