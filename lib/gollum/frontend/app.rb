require 'rubygems'

require 'sinatra'
require 'gollum'
require 'mustache/sinatra'

require 'gollum/frontend/views/layout'

$path = "~/dev/mojombo/gollum/test/examples/lotr.git"

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra

    dir = File.dirname(File.expand_path(__FILE__))

    # We want to serve public assets for now
    set :public,    "#{dir}/public"
    set :static,    true

    set :mustache, {
      # Tell mustache where the Views constant lives
      :namespace => Precious,

      # Mustache templates live here
      :templates => "#{dir}/templates",

      # Tell mustache where the views are
      :views => "#{dir}/views"
    }

    # Sinatra error handling
    configure :development, :staging do
      set :raise_errors, false
      set :show_exceptions, true
      set :dump_errors, true
      set :clean_trace, false
    end

    get '/' do
      show_page_or_file('Home')
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(name)
      wiki = Gollum::Wiki.new($path)
      if page = wiki.page(name)
        @content = page.formatted_data
        mustache :page
      elsif file = wiki.file(name)
        file.raw_data
      else
        halt 404
      end
    end
  end
end

Precious::App.run!
