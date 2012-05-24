require 'cgi'
require 'sinatra'
require 'gollum'
require 'mustache/sinatra'

require 'gollum/frontend/views/layout'
require 'gollum/frontend/views/editable'

require File.expand_path '../uri_encode_component', __FILE__

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra

    dir = File.dirname(File.expand_path(__FILE__))

    # We want to serve public assets for now
    set :public_folder, "#{dir}/public/gollum"
    set :static,         true
    set :default_markup, :html

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

    # Deagol helper function - this allows us to manage repositories
    # with directories etc...
    def set_the_path(file_path)
      path = file_path.dup
      if path != '' && path != '/' && path.include?('/')
        path.sub!(/\/[\w\-\_\.]*$/,'')
        path.sub!(/^\//,'')
      else
        path = nil
      end
      path
    end

    get '/' do
      redirect '/pages'
    end

    get '/data/*' do
      @path        = set_the_path(params[:splat].first)
      @name        = params[:splat].first.split("/").last
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      if page = wiki.page(@name)
        page.raw_data
      end
    end

    get '/edit/*' do
      @path        = set_the_path(params[:splat].first)
      @name        = params[:splat].first.split("/").last
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      if page = wiki.page(@name)
        if page.format.to_s.include?('markdown')
          redirect '/livepreview/index.html?page=' + encodeURIComponent(@name)
        else
          @page = page
          @page.version = wiki.repo.log(wiki.ref, @page.path).first
          @content = page.raw_data
          mustache :edit
        end
      else
        mustache :create
      end
    end

    post '/edit/*' do
      @path        = set_the_path(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      page         = wiki.page(params[:splat].first.split("/").last)
      name         = params[:rename] || page.name
      committer    = Gollum::Committer.new(wiki, commit_message)
      commit       = {:committer => committer}

      update_wiki_page(wiki, page, params[:content], commit, name, params[:format])
      update_wiki_page(wiki, page.header,  params[:header],  commit) if params[:header]
      update_wiki_page(wiki, page.footer,  params[:footer],  commit) if params[:footer]
      update_wiki_page(wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
      committer.commit

      redirect "/#{CGI.escape(page.path).gsub('%2F','/')}"
    end

    post '/create' do
      name   = params[:page]
      wiki   = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      format = params[:format].intern

      begin
        wiki.write_page(name, format, params[:content], commit_message)
        redirect "/#{CGI.escape(page.path)}"
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/:page/:version_list' do
      @path        = set_the_path(params[:page].dup)
      @name        = params[:page].split('/').last
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @page        = wiki.page(@name)
      @versions    = params[:version_list].split(/\.{2,3}/)
      sha1         = @versions.first
      sha2         = @versions.last

      if wiki.revert_page(@page, sha1, sha2, commit_message)
        redirect "/#{CGI.escape(@page.path).gsub('%2F','/')}"
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
      wiki      = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      @name     = "Preview"
      @page     = wiki.preview_page(@name, params[:content], params[:format])
      @content  = @page.formatted_data
      @editable = false
      mustache :page
    end

    get '/history/*' do
      @path        = set_the_path(params[:splat].first)
      @name        = params[:splat].first.split("/").last
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @page        = wiki.page(@name)
      @page_num    = [params[:page].to_i, 1].max
      @versions    = @page.versions :page => @page_num
      mustache :history
    end

    post '/compare/*' do
      @file     = params[:splat].first
      @versions = params[:versions] || []
      if @versions.size < 2
        redirect "/history/#{CGI.escape(@file)}"
      else
        redirect "/compare/%s/%s...%s" % [
          CGI.escape(@file),
          @versions.last,
          @versions.first]
      end
    end

    get '/compare/:name/:version_list' do
      @path        = set_the_path(params[:name].dup)
      @name        = params[:name].split('/').last
      @versions    = params[:version_list].split(/\.{2,3}/)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @page        = wiki.page(@name)
      diffs        = wiki.repo.diff(@versions.first, @versions.last, @page.path)
      @diff        = diffs.first
      mustache :compare
    end

    get '/_tex.png' do
      content_type 'image/png'
      formula = Base64.decode64(params[:data])
      Gollum::Tex.render_formula(formula)
    end

    get %r{^/(javascript|css|images)} do
      halt 404
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      file_path    = params[:captures][0]
      path         = set_the_path(file_path.dup)
      name         = file_path.split('/').last
      wiki_options = settings.wiki_options.merge({ :page_file_dir => path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)

      if page = wiki.page(name, params[:captures][1])
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
        mustache :page
      else
        halt 404
      end
    end

    get '/search' do
      @query = params[:q]
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      @results = wiki.search @query
      @name = @query
      mustache :search
    end

    get '/pages*' do
      @path        = set_the_path(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @results     = wiki.pages
      @ref         = wiki.ref
      mustache :pages
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(name)
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      if page = wiki.page(name)
        @page = page
        @name = name
        @content = page.formatted_data
        @editable = true
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
      return if !page ||
        ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format    = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit_message)
    end

    def commit_message
      { :message => params[:message] }
    end
  end
end
