#!/usr/bin/env ruby
require 'rubygems'
require 'gollum/app'

# Initialize the wiki
if !File.directory?('.git')
  `git init`
end

# Add in commit user/email
class Precious::App
  before do
    session['gollum.author'] = {
      :name => ENV['GOLLUM_AUTHOR_USERNAME'].to_s != '' ? ENV['GOLLUM_AUTHOR_USERNAME'] : 'Anonymous',
      :email => ENV['GOLLUM_AUTHOR_EMAIL'].to_s != '' ? ENV['GOLLUM_AUTHOR_EMAIL'] : 'anon@anon.com',
    }
  end
end

# Start gollum service
load '/usr/local/bundle/bin/gollum'
