
require 'rubygems'
require 'gollum/app'

use Rack::Session::Cookie, :key => 'rack.session',
  :path => '/',
  :secret => 'your_secret'

gollum_path = File.expand_path(File.dirname(__FILE__)) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {:universal_toc => false})
run Precious::App
