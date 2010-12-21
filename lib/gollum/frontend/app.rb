require 'cgi'
require 'sinatra'
require 'gollum'
require 'mustache/sinatra'

require 'gollum/frontend/views/layout'
require 'gollum/frontend/views/editable'

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
      enable :show_exceptions, :dump_errors
      disable :raise_errors, :clean_trace
    end

    configure :test do
      enable :logging, :raise_errors, :dump_errors
    end

    get '/' do
      show_page_or_file('Home')
    end

    get '/edit/*' do
      @name = params[:splat].first
      wiki = Gollum::Wiki.new(settings.gollum_path)
      if page = wiki.page(@name)
        @page = page
        @content = page.raw_data
        mustache :edit
      else
        mustache :create
      end
    end

    post '/edit/*' do
      wiki = Gollum::Wiki.new(settings.gollum_path)
      page = wiki.page(params[:splat].first)
      name = params[:rename] || page.name
      msg  = commit_message
      update_wiki_page(wiki, page, params[:content], msg, name, 
        params[:format])
      update_wiki_page(wiki, page.footer,  params[:footer],  msg) if params[:footer]
      update_wiki_page(wiki, page.sidebar, params[:sidebar], msg) if params[:sidebar]

      redirect "/#{CGI.escape(Gollum::Page.cname(name))}"
    end

    post '/create' do
      name = params[:page]
      wiki = Gollum::Wiki.new(settings.gollum_path)

      format = params[:format].intern

      begin
        wiki.write_page(name, format, params[:content], commit_message)
        redirect "/#{CGI.escape(name)}"
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/:page/*' do
      wiki  = Gollum::Wiki.new(settings.gollum_path)
      @name = params[:page]
      @page = wiki.page(@name)
      shas  = params[:splat].first.split("/")
      sha1  = shas.shift
      sha2  = shas.shift

      if wiki.revert_page(@page, sha1, sha2, commit_message)
        redirect "/#{CGI.escape(@name)}"
      else
        sha2, sha1 = sha1, "#{sha1}^" if !sha2
        @versions = [sha1, sha2]
        diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
        @diff     = diffs.first
        @message  = "The patch does not apply."
        mustache :compare
      end
    end

    post '/preview' do
      wiki     = Gollum::Wiki.new(settings.gollum_path)
      @name    = "Preview"
      @page    = wiki.preview_page(@name, params[:content], params[:format])
      @content = @page.formatted_data
      mustache :page
    end

    get '/history/:name' do
      @name     = params[:name]
      wiki      = Gollum::Wiki.new(settings.gollum_path)
      @page     = wiki.page(@name)
      @page_num = [params[:page].to_i, 1].max
      @versions = @page.versions :page => @page_num
      mustache :history
    end

    post '/compare/:name' do
      @versions = params[:versions] || []
      if @versions.size < 2
        redirect "/history/#{CGI.escape(params[:name])}"
      else
        redirect "/compare/%s/%s...%s" % [
          CGI.escape(params[:name]),
          @versions.last,
          @versions.first]
      end
    end

    get '/compare/:name/:version_list' do
      @name     = params[:name]
      @versions = params[:version_list].split(/\.{2,3}/)
      wiki      = Gollum::Wiki.new(settings.gollum_path)
      @page     = wiki.page(@name)
      diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
      @diff     = diffs.first
      mustache :compare
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      name = params[:captures][0]
      wiki = Gollum::Wiki.new(settings.gollum_path)
      if page = wiki.page(name, params[:captures][1])
        @page = page
        @name = name
        @content = page.formatted_data
        mustache :page
      else
        halt 404
      end
    end

    get '/search' do
      @query = params[:q]
      wiki = Gollum::Wiki.new(settings.gollum_path)
      @results = wiki.search @query
      @name = @query
      mustache :search
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(name)
      wiki = Gollum::Wiki.new(settings.gollum_path)
      if page = wiki.page(name)
        @page = page
        @name = name
        @content = page.formatted_data
        mustache :page
      elsif file = wiki.file(name)
        content_type file.mime_type
        file.raw_data
      else
        @name = name
        mustache :create
      end
    end

    def update_wiki_page(wiki, page, content, commit_message, name = nil, format = nil)
      return if !page || !content || page.raw_data == content
      name ||= page.name
      format = (format || page.format).to_sym
      wiki.update_page(page, name, format, content, commit_message)
    end

    def commit_message
      { :message => params[:message] }
    end
  end
end
