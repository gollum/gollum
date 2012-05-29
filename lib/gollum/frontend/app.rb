require 'cgi'
require 'pathname'
require 'sinatra'
require 'gollum'
require 'mustache/sinatra'

require 'gollum/frontend/views/layout'
require 'gollum/frontend/views/editable'

require File.expand_path '../uri_encode_component', __FILE__
require File.expand_path '../ldap_authentication', __FILE__

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra
    include LdapAuthentication

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

    # Deagol helper functions
    helpers do
      def authentication_required!
        @current_user = current_user
        redirect '/login' unless @current_user
      end

      def current_user
        email = request.cookies['email']
        name  = request.cookies['name']
        token = request.cookies['token']

        if email && name && token && token_ok?(email,token)
          { :email => email, :name => name, :token => token }
        end
      end

      # Extract the path string that Gollum::Wiki expects
      def extract_path(file_path)
        pn = Pathname.new(file_path.dup).dirname.to_s.sub(/^\//,'')
        pn unless ['','.','/'].include?(pn)
      end

      # Extract the 'page' name from the file_path
      def extract_name(file_path)
        file_path.split("/").last
      end

      # Extrace the 'format' from the file name
      def extract_format(filename)
        $1 if filename =~ /^.+\.(\w+)$/
      end
    end

    get '/login' do
      mustache :login
    end

    post '/login' do
      login    = params[:login]
      password = params[:password]

      @current_user = authenticate(login, password)

      if @current_user
        response.set_cookie('email', @current_user[:email])
        response.set_cookie('name', @current_user[:name])
        response.set_cookie('token', @current_user[:token])
        redirect '/'
      else
        redirect '/login'
      end
    end

    get '/logout' do
      response.set_cookie('email', false)
      response.set_cookie('name', false)
      response.set_cookie('token', false)
      redirect '/login'
    end

    get '/' do
      redirect '/pages'
    end

    get '/data/*' do
      authentication_required!
      @path        = extract_path(params[:splat].first)
      @name        = extract_name(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      if page = wiki.page(@name)
        page.raw_data
      end
    end

    get '/edit/*' do
      authentication_required!
      @path        = extract_path(params[:splat].first)
      @name        = extract_name(params[:splat].first)
      @format      = extract_format(@name)
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
      authentication_required!
      @path        = extract_path(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      page         = wiki.page(extract_name(params[:splat].first))
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
      authentication_required!
      name         = params[:page].split('/').last
      path         = extract_path(params[:page].dup)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)

      filename_to_write = name.dup
      format            = params[:format].intern
      if filename_to_write =~ /^(.+)\.#{format}$/
        filename_to_write = $1
      end

      begin
        wiki.write_page(filename_to_write, format, params[:content], commit_message)
        page = wiki.page(name)
        redirect "/#{CGI.escape(page.path).gsub('%2F','/')}"
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/:page/:version_list' do
      authentication_required!
      @path        = extract_path(params[:page].dup)
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
      authentication_required!
      wiki      = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      @name     = "Preview"
      @page     = wiki.preview_page(@name, params[:content], params[:format])
      @content  = @page.formatted_data
      @editable = false
      mustache :page
    end

    get '/history/*' do
      authentication_required!
      @path        = extract_path(params[:splat].first)
      @name        = extract_name(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @page        = wiki.page(@name)
      @page_num    = [params[:page].to_i, 1].max
      @versions    = @page.versions :page => @page_num
      mustache :history
    end

    post '/compare/*' do
      authentication_required!
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
      authentication_required!
      @path        = extract_path(params[:name].dup)
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
      authentication_required!
      content_type 'image/png'
      formula = Base64.decode64(params[:data])
      Gollum::Tex.render_formula(formula)
    end

    get %r{^/(javascript|css|images)} do
      halt 404
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      authentication_required!
      file_path    = params[:captures][0]
      path         = extract_path(file_path.dup)
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
      authentication_required!
      @query = params[:q]
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      @results = wiki.search @query
      @name = @query
      mustache :search
    end

    get '/pages*' do
      authentication_required!
      @path        = extract_path(params[:splat].first)
      wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
      @results     = wiki.pages
      @ref         = wiki.ref
      mustache :pages
    end

    get '/*' do
      authentication_required!
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
        @name   = name
        @format = extract_format(@name)
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
