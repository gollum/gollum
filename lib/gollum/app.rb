# ~*~ encoding: utf-8 ~*~
require 'cgi'
require 'sinatra'
require 'sinatra/namespace'
require 'gollum-lib'
require 'mustache/sinatra'
require 'stringex'
require 'json'
require 'sprockets'
require 'sprockets-helpers'
require 'uglifier'
require 'sass'

require 'gollum'
require 'gollum/assets'
require 'gollum/views/helpers'
require 'gollum/views/layout'
require 'gollum/views/editable'
require 'gollum/views/has_page'

require File.expand_path '../helpers', __FILE__

#required to upload bigger binary files
Gollum::set_git_timeout(120)
Gollum::set_git_max_filesize(190 * 10**6)

# Use stringex #to_url only to leverage its #to_ascii method when using grit
class String
  if Gollum::GIT_ADAPTER != 'grit'
    def to_ascii
      self # Do not transliterate utf-8 url's unless using Grit
    end
  end

  def to_url
    to_ascii
  end
end

# Run the frontend, based on Sinatra
#
# There are a number of wiki options that can be set for the frontend
#
# Example
# require 'gollum/app'
# Precious::App.set(:wiki_options, {
#     :universal_toc => false,
# }
#
# See the wiki.rb file for more details on wiki options

module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra
    register Sinatra::Namespace
    include Precious::Helpers
    dir = File.dirname(File.expand_path(__FILE__))

    set :sprockets, ::Precious::Assets.sprockets(dir)

    set :default_markup, :markdown

    set :mustache, {
        # Tell mustache where the Views constant lives
        :namespace => Precious,

        # Mustache templates live here
        :templates => "#{dir}/templates",

        # Tell mustache where the views are
        :views     => "#{dir}/views"
    }

    # Sinatra error handling
    configure :development, :staging do
      enable :show_exceptions, :dump_errors
      disable :raise_errors, :clean_trace
    end

    configure :test do
      enable :logging, :raise_errors, :dump_errors
    end

    before do
      settings.wiki_options[:allow_editing] = settings.wiki_options.fetch(:allow_editing, true)
      @allow_editing = settings.wiki_options[:allow_editing]
      forbid unless @allow_editing || request.request_method == "GET"
      Precious::App.set(:mustache, {:templates => settings.wiki_options[:template_dir]}) if settings.wiki_options[:template_dir]
      @base_url = url('/', false).chomp('/').force_encoding('utf-8')
      @page_dir = settings.wiki_options[:page_file_dir].to_s
      # above will detect base_path when it's used with map in a config.ru
      settings.wiki_options.merge!({ :base_path => @base_url })
      @css = settings.wiki_options[:css]
      @js  = settings.wiki_options[:js]
      @mathjax_config = settings.wiki_options[:mathjax_config]

      @use_static_assets = settings.wiki_options.fetch(:static, settings.environment == :production || settings.environment == :staging)
      @static_assets_path = settings.wiki_options.fetch(:static_assets_path, './public/assets')

      Sprockets::Helpers.configure do |config|
        config.environment = settings.sprockets
        config.environment.context_class.class_variable_set(:@@base_url, @base_url)
        config.prefix      = "#{@base_url}/#{Precious::Assets::ASSET_URL}"
        config.digest      = @use_static_assets
        if @use_static_assets
          config.public_path = @static_assets_path
          config.manifest = Sprockets::Manifest.new(settings.sprockets, @static_assets_path)
        end
      end
    end

    get '/' do
      redirect clean_url(::File.join(@base_url, @page_dir, wiki_new.index_page))
    end

    namespace '/gollum' do

      get '/assets/*' do
        env['PATH_INFO'].sub!("/#{Precious::Assets::ASSET_URL}", '')
        if @use_static_assets
          env['PATH_INFO'].sub!(Sprockets::Helpers.prefix, '') if @base_url
          not_found_msg = "Not found." 
          not_found = Proc.new {[404, {'Content-Type' => 'text/html', 'Content-Length' => not_found_msg.length.to_s}, [not_found_msg]]}
          Rack::Static.new(not_found, {:root => @static_assets_path, :urls => ['']}).call(env)
        else
          settings.sprockets.call(env)
        end
      end

      get '/last_commit_info' do
        content_type :json
        if page = wiki_page(params[:path]).page
          version = page.last_version
          {:author => version.author.name, :date => version.authored_date}.to_json
        end
      end

      get '/emoji/:name' do
        begin
          [200, {'Content-Type' => 'image/png'}, emoji(params['name'])]
        rescue ArgumentError
          not_found
        end
      end

      get '/data/*' do
        if page = wiki_page(params[:splat].first).page
          page.raw_data
        end
      end

      get %r{/(edit|create)/custom\.(js|css)} do
        forbid('Changing this resource is not allowed.')
      end

      post %r{/(delete|rename|edit|create)/custom\.(js|css)} do
        forbid('Changing this resource is not allowed.')
      end

      post %r{/revert/custom\.(js|css)/.*/.*} do
        forbid('Changing this resource is not allowed.')
      end

      get '/edit/*' do
        forbid unless @allow_editing
        wikip = wiki_page(params[:splat].first)
        @name = join_page_name(wikip.name, wikip.ext)
        @path = wikip.path
        @upload_dest   = find_upload_dest(@path)

        wiki = wikip.wiki
        @allow_uploads = wiki.allow_uploads
          if page = wikip.page
              @page         = page
              @page.version = wiki.repo.log(wiki.ref, @page.path).first
              @content      = page.text_data
              mustache :edit
          else
            redirect_to("/create/#{encodeURIComponent(@name)}")
          end
        end

      post '/upload_file' do
        wiki = wiki_new

        unless wiki.allow_uploads
          @message = "File uploads are disabled"
          mustache :error
          return
        end

        if params[:file]
          fullname = params[:file][:filename]
          tempfile = params[:file][:tempfile]
        end
        halt 500 unless tempfile.is_a? Tempfile

        # Remove page file dir prefix from upload path if necessary -- committer handles this itself
        dir      = wiki.per_page_uploads ? params[:upload_dest] : ::File.join([wiki.page_file_dir, 'uploads'].compact)
        ext      = ::File.extname(fullname)
        format   = ext.split('.').last || 'txt'
        filename = ::File.basename(fullname, ext)
        contents = ::File.read(tempfile)
        reponame = "#{filename}.#{format}"

        head = wiki.repo.head

        options = {
            :message => "Uploaded file to #{dir}/#{reponame}",
            :parent  => wiki.repo.head.commit,
        }
        author  = session['gollum.author']
        unless author.nil?
          options.merge! author
        end

        begin
          committer = Gollum::Committer.new(wiki, options)
          committer.add_to_index(dir, filename, format, contents)
          committer.after_commit do |committer, sha|
            wiki.clear_cache
            committer.update_working_dir(dir, filename, format)
          end
          committer.commit
          redirect to(request.referer)
        rescue Gollum::DuplicatePageError => e
          @message = "Duplicate page: #{e.message}"
          mustache :error
        end
      end


      post '/rename/*' do
        wikip = wiki_page(params[:splat].first)
        halt 500 if wikip.nil?
        wiki   = wikip.wiki
        page   = wiki.paged(join_page_name(wikip.name, wikip.ext), wikip.path, exact = true)
        rename = params[:rename]
        halt 500 if page.nil?
        halt 500 if rename.nil? or rename.empty?

        # Fixup the rename if it is a relative path
        # In 1.8.7 rename[0] != rename[0..0]
        if rename[0..0] != '/'
          source_dir                = ::File.dirname(page.path)
          source_dir                = '' if source_dir == '.'
          (target_dir, target_name) = ::File.split(rename)
          target_dir                = target_dir == '' ? source_dir : "#{source_dir}/#{target_dir}"
          rename                    = "#{target_dir}/#{target_name}"
        end

        committer = Gollum::Committer.new(wiki, commit_message)
        commit    = { :committer => committer }

        success = wiki.rename_page(page, rename, commit)
        if !success
          # This occurs on NOOPs, for example renaming A => A
          redirect to("/#{page.escaped_url_path}")
          return
        end
        committer.commit

        wikip = wiki_page(rename)
        page  = wiki.paged(join_page_name(wikip.name, wikip.ext), wikip.path, exact = true)
        return if page.nil?
        redirect to("/#{page.escaped_url_path}")
      end

      post '/edit/*' do
        path      = "/#{clean_url(sanitize_empty_params(params[:path]))}"
        page_name = CGI.unescape(params[:page])
        wiki      = wiki_new
        page      = wiki.paged(page_name, path, exact = true)
        return if page.nil?
        committer = Gollum::Committer.new(wiki, commit_message)
        commit    = { :committer => committer }

        update_wiki_page(wiki, page, params[:content], commit, page.name, params[:format])
        update_wiki_page(wiki, page.header, params[:header], commit) if params[:header]
        update_wiki_page(wiki, page.footer, params[:footer], commit) if params[:footer]
        update_wiki_page(wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
        committer.commit

        redirect to("/#{page.escaped_url_path}") unless page.nil?
      end


      post '/delete/*' do
        forbid unless @allow_editing
        wiki = wiki_new
        filepath = params[:splat].first
        unless filepath.nil?
          commit           = commit_message
          commit[:message] = "Deleted #{filepath}"
          wiki.delete_file(filepath, commit)
        end
      end
      

      get '/create/*' do
        forbid unless @allow_editing
        if settings.wiki_options[:template_page] then
          temppage = wiki_page("/_Template")
          @template_page = (temppage.page != nil) ? temppage.page.raw_data : "Template page option is set, but no /_Template page is present or committed."
        end
        wikip = wiki_page(params[:splat].first)
        @name = wikip.name.to_url
        @ext  = wikip.ext
        @path = wikip.path
        @allow_uploads = wikip.wiki.allow_uploads
        @upload_dest   = find_upload_dest(@path)

        page_dir = settings.wiki_options[:page_file_dir].to_s
        unless page_dir.empty?
          # --page-file-dir docs
          # /docs/Home should be created in /Home
          # not /docs/Home because write_page will append /docs
          @path = @path.sub(page_dir, '/') if @path.start_with? page_dir
        end
        @path = clean_path(@path)

        page = wikip.page
        if page
          page_dir = settings.wiki_options[:page_file_dir].to_s
          redirect to("/#{clean_url(::File.join(page_dir, page.escaped_url_path))}")
        else
          unless Gollum::Page.format_for("#{@name}#{@ext}")
            @name = "#{@name}#{@ext}"
            @ext = nil
          end
          mustache :create
        end
      end

      post '/create' do
        name   = params[:page].to_url
        path   = sanitize_empty_params(params[:path]) || ''
        format = params[:format].intern
        wiki   = wiki_new

        path.gsub!(/^\//, '')

        begin
          wiki.write_page(name, format, params[:content], commit_message, path)

          page_dir = settings.wiki_options[:page_file_dir].to_s
          redirect to("/#{clean_url(::File.join(encodeURIComponent(page_dir), encodeURIComponent(path), encodeURIComponent(wiki.page_file_name(name, format))))}")
        rescue Gollum::DuplicatePageError => e
          @message = "Duplicate page: #{e.message}"
          mustache :error
        end
      end

      post '/revert/*/:sha1/:sha2' do
        wikip = wiki_page(params[:splat].first)
        @path = wikip.path
        @name = join_page_name(wikip.name, wikip.ext)
        wiki  = wikip.wiki
        @page = wiki.paged(@name, @path)
        sha1  = params[:sha1]
        sha2  = params[:sha2]

        commit           = commit_message
        commit[:message] = "Revert commit #{sha1.chars.take(7).join}"
        if wiki.revert_page(@page, sha1, sha2, commit)
          redirect to("/#{@page.escaped_url_path}")
        else
          sha2, sha1 = sha1, "#{sha1}^" if !sha2
          @versions  = [sha1, sha2]
          diffs      = wiki.repo.diff(@versions.first, @versions.last, @page.path)
          @diff      = diffs.first
          @message   = "The patch does not apply."
          mustache :compare
        end
      end

      post '/preview' do
        wiki           = wiki_new
        @name          = params[:page] || "Preview"
        @page          = wiki.preview_page(@name, params[:content], params[:format])
        @content       = @page.formatted_data
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @mathjax       = wiki.mathjax
        @h1_title      = wiki.h1_title
        @editable      = false
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads
        mustache :page
      end

      get '/history/*' do
        @page     = wiki_page(params[:splat].first).page
        @page_num = [params[:page].to_i, 1].max
        unless @page.nil?
          @versions = @page.versions(:page => @page_num, :follow => settings.wiki_options.fetch(:follow_renames, ::Gollum::GIT_ADAPTER == 'rjgit' ? false : true))
          mustache :history
        else
          redirect to("/")
        end
      end

      get '/latest_changes' do
        @wiki = wiki_new
        max_count = settings.wiki_options.fetch(:latest_changes_count, 10)
        @versions = @wiki.latest_changes({:max_count => max_count})
        mustache :latest_changes
      end

      post '/compare/*' do
        @file     = encodeURIComponent(params[:splat].first)
        @versions = params[:versions] || []
        if @versions.size < 2
          redirect_to("/history/#{@file}")
        else
          redirect_to("/compare/%s/%s...%s" % [
              @file,
              @versions.last,
              @versions.first]
                   )
        end
      end

      get %r{
        /compare/ # match any URL beginning with /compare/
        (.+)      # extract the full path (including any directories)
        /         # match the final slash
        ([^.]+)   # match the first SHA1
        \.{2,3}   # match .. or ...
        (.+)      # match the second SHA1
      }x do |path, start_version, end_version|
        wikip     = wiki_page(path)
        @path     = wikip.path
        @name     = join_page_name(wikip.name, wikip.ext)
        @versions = [start_version, end_version]
        wiki      = wikip.wiki
        @page     = wikip.page
        diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
        @diff     = diffs.first
        mustache :compare
      end

      get '/search' do
        @query   = params[:q] || ''
        wiki     = wiki_new
        # Sort wiki search results by count (desc) and then by name (asc)
        @results = wiki.search(@query).sort { |a, b| (a[:count] <=> b[:count]).nonzero? || b[:name] <=> a[:name] }.reverse
        @name    = @query
        mustache :search
      end

      get %r{
        /pages  # match any URL beginning with /pages
        (?:     # begin an optional non-capturing group
          /(.+) # capture any path after the "/pages" excluding the leading slash
        )?      # end the optional non-capturing group
      }x do |path|
        @path        = extract_path(path) if path
        wiki_options = settings.wiki_options.merge({ :page_file_dir => @path })
        wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)
        @results     = wiki.pages
        @results     += wiki.files
        @results     = @results.sort_by { |p| p.name.downcase } # Sort Results alphabetically, fixes 922
        @ref         = wiki.ref
        mustache :pages
      end
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      file_path = params[:captures][0]
      version   = params[:captures][1]
      wikip     = wiki_page(file_path, file_path, version)
      name      = join_page_name(wikip.name, wikip.ext)
      path      = wikip.path
      if page = wikip.page
        @page    = page
        @name    = name
        @content = page.formatted_data
        @version = version
        @bar_side = wikip.wiki.bar_side
        mustache :page
      elsif file = wikip.wiki.file("#{file_path}", version, true)
        show_file(file)
      else
        halt 404
      end
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    private

    def show_page_or_file(fullpath)
      wiki = wiki_new

      name, ext = extract_name(fullpath) || wiki.index_page
      path = extract_path(fullpath) || '/'
      if page = wiki.paged(join_page_name(name, ext), path, exact = true)
        @page          = page
        @name          = name
        @content       = page.formatted_data
        @upload_dest   = find_upload_dest(path)

        # Extensions and layout data
        @editable      = true
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @mathjax       = wiki.mathjax
        @h1_title      = wiki.h1_title
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads

        mustache :page
      elsif file = wiki.file(fullpath, wiki.ref, true)
        show_file(file)
      else
        if @allow_editing
          page_path = [path, join_page_name(name, ext)].compact.join('/')
          redirect to("/gollum/create/#{clean_url(encodeURIComponent(page_path))}")
        else
          @message = "The requested page does not exist."
          status 404
          return mustache :error
        end
      end
    end
    
    def show_file(file)
      return unless file
      if file.on_disk?
        send_file file.on_disk_path, :disposition => 'inline'
      else
        content_type file.mime_type
        file.raw_data
      end
    end

    def update_wiki_page(wiki, page, content, commit, name = nil, format = nil)
      return if !page ||
          ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format  = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit)
    end

    #  path is set to name if path is nil.
    #  if path is 'a/b' and a and b are dirs, then
    #  path must have a trailing slash 'a/b/' or
    #  extract_path will trim path to 'a'
    def wiki_page(name, path = nil, version = nil, exact = true)
      wiki = wiki_new
      path = name if path.nil?
      name, ext = extract_name(name) || wiki.index_page
      path = extract_path(path)
      path = '/' if exact && path.nil?

      OpenStruct.new(:wiki => wiki, :page => wiki.paged(join_page_name(name, ext), path, exact, version),
                     :name => name, :path => path, :ext => ext)
    end

    def wiki_new
      Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    end

    # Options parameter to Gollum::Committer#initialize
    #     :message   - The String commit message.
    #     :name      - The String author full name.
    #     :email     - The String email address.
    # message is sourced from the incoming request parameters
    # author details are sourced from the session, to be populated by rack middleware ahead of us
    def commit_message
      msg               = (params[:message].nil? or params[:message].empty?) ? "[no message]" : params[:message]
      commit_message    = { :message => msg }
      author_parameters = session['gollum.author']
      commit_message.merge! author_parameters unless author_parameters.nil?
      commit_message
    end

    def find_upload_dest(path)
      settings.wiki_options[:allow_uploads] ?
          (settings.wiki_options[:per_page_uploads] ?
              "#{path}/#{@name}".sub(/^\/\//, '') : 'uploads'
          ) : ''
    end
  end
end
