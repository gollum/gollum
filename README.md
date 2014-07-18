## Rejuvenation PI Wiki

View the [Original Gollum Readme Here](http://www.github.com/gollum/gollum)

The Rejuvenation PI Wiki is a slightly customized Gollum Wiki.

Here is a list of features found in the Rejuvneation Fork

### User Authentication

The fork of gollum has a simple authentication platform built in. The system reads lines from a TXT file containing user names, and matches them all to the same password. This means that every user has the same password, however if no user is found they will not be logged in.

### Text Area file upload

Drag and drop file upload is also supported in the textareas of the wiki. This allows users to upload PDFs or product images with ease.

## Running The Wiki

The wiki can be ran on any server with relative ease. It can be started from the command line with the `gollum` command, however due to the customizations included in the fork, it's recommende you use a `config.ru` file and the `rackup` command.

**Note:** You can pass the `-p` flag to change the port rackup uses

The following config.ru file should give you a good starting point

```ruby
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
  :universal_toc => true,
  :allow_uploads => true,
  :live_preview => false
})
run Precious::App
```

This file will load up your users.txt file, set the password for your environment, as well as enable rack sessions.

Currently the wiki is running in a screen session with NGINX looking at port 4567, so to start it up follow these steps

  - `screen`
  - `rackup -p 4567`
  - control a+d

## Updating the Wiki

To update the wiki gem on the server follow these steps

  - SSH Onto your host
  - Pull this repo onto the server
  - CD into the repo's directory
  - Run `rake build` - This will build the source into a gemfile
  - Run `gem uninstall gollum` to uninstall the current version
  - Run 'gem install pkg/gollum.....gem` Note: The verison may change, but you should be able to tab complete after gollum to install

If the server is running gollum in a screen session run these commands:
  - `screen -r`
  - control+c
  - `rackup -p 4567`
