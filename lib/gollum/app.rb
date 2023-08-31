# encoding: UTF-8

require 'cgi'
require 'sinatra'
require 'sinatra/namespace'
require 'gollum-lib'
require 'mustache/sinatra'
require 'json'
require 'sprockets'
require 'sprockets-helpers'
require 'octicons'
require 'pathname'

require 'gollum'
require 'gollum/assets'

# Requirements for loading the layout view:
require 'gollum/views/helpers'
require 'gollum/views/helpers/locale_helpers'
require 'gollum/views/template_cascade'

require 'gollum/views/layout'
require 'gollum/views/editable'
require 'gollum/views/has_page'
require 'gollum/views/has_user_icons'
require 'gollum/views/has_math'
require 'gollum/views/pagination'
require 'gollum/views/rss.rb'

['sassc', 'sassc-embedded'].each do |gem|
  require gem if Gem::Specification.find {|spec| spec.name == gem}
end

require File.expand_path '../helpers', __FILE__

#required to upload bigger binary files
Gollum::set_git_timeout(120)
Gollum::set_git_max_filesize(190 * 10**6)

Gollum::Filter::Code.language_handlers[/mermaid/] = Proc.new { |lang, code| "<div class=\"mermaid\">\n#{code}\n</div>" }

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

  # For use with the --base-path option.
  class MapGollum
    def initialize(base_path)
      @mg = Rack::Builder.new do

        map "/#{base_path}" do
          run Precious::App
        end
        map '/' do
          run Proc.new { [302, { 'Location' => "/#{base_path}" }, []] }
        end
        map '/*' do
          run Proc.new { [302, { 'Location' => "/#{base_path}" }, []] }
        end

      end
    end

    def call(env)
      @mg.call(env)
    end
  end

  class App < Sinatra::Base
    register Mustache::Sinatra
    register Sinatra::Namespace
    include Precious::Helpers

    Encoding.default_external = "UTF-8"

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
      @allow_editing = settings.wiki_options.fetch(:allow_editing, true)
      @critic_markup = settings.wiki_options[:critic_markup]
      @redirects_enabled = settings.wiki_options.fetch(:redirects_enabled, true)
      @per_page_uploads = settings.wiki_options[:per_page_uploads]
      @show_local_time = settings.wiki_options.fetch(:show_local_time, false)
      
      @wiki_title = settings.wiki_options.fetch(:title, 'Gollum Wiki')
      @default_keybinding = settings.wiki_options.fetch(:default_keybinding, 'default')

      if settings.wiki_options[:template_dir]
        Precious::Views::Layout.template_priority_path = settings.wiki_options[:template_dir]
      end

      @base_url = url('/', false).chomp('/').force_encoding('utf-8')
      @page_dir = settings.wiki_options[:page_file_dir].to_s

      # above will detect base_path when it's used with map in a config.ru
      settings.wiki_options.merge!({ :base_path => @base_url })
      @css = settings.wiki_options[:css]
      @js  = settings.wiki_options[:js]
      @math = settings.wiki_options[:math]
      @math_config = settings.wiki_options.fetch(:math_config, false)
      @mermaid = settings.wiki_options.fetch(:mermaid, true)
      Gollum::Filter::Code.language_handlers.delete(/mermaid/) unless @mermaid

      @use_static_assets = settings.wiki_options.fetch(:static, settings.environment != :development)
      @static_assets_path = settings.wiki_options.fetch(:static_assets_path, ::File.join(File.dirname(__FILE__), 'public/assets'))
      @mathjax_path = ::File.join(File.dirname(__FILE__), 'public/gollum/javascript/MathJax')

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

      forbid unless @allow_editing || request.request_method == 'GET'
    end

    get '/' do
      redirect clean_url(::File.join(@base_url, wiki_new.index_page))
    end

    namespace '/gollum' do
      get '/feed/' do
        url = "#{env['rack.url_scheme']}://#{env['HTTP_HOST']}"
        changes = wiki_new.latest_changes(::Gollum::Page.log_pagination_options(
          per_page: settings.wiki_options.fetch(:pagination_count, 10),
          page_num: 0)
        )
        content_type :rss
        RSSView.new(@base_url, @wiki_title, url, changes).render
      end

      get '/assets/mathjax/*' do
        env['PATH_INFO'].sub!('/gollum/assets/mathjax', '')
        Rack::Static.new(not_found_proc, {:root => @mathjax_path, :urls => ['']}).call(env)
      end

      get '/assets/*' do
        env['PATH_INFO'].sub!("/#{Precious::Assets::ASSET_URL}", '')
        if @use_static_assets
          env['PATH_INFO'].sub!(Sprockets::Helpers.prefix, '') if @base_url
          Rack::Static.new(not_found_proc, {:root => @static_assets_path, :urls => ['']}).call(env)
        else
          settings.sprockets.call(env)
        end
      end

      get '/last_commit_info' do
        content_type :json
        if page = wiki_page(params[:path]).page
          version = page.last_version
          authored_date = version.authored_date
          authored_date = authored_date.utc.iso8601 if @show_local_time
          {:author => version.author.name, :date => authored_date}.to_json
        end
      end

      include Precious::Views::OcticonHelpers
      get '/octicon/:name' do
        begin
          [200, {'Content-Type' => 'image/svg'}, rocticon_css(params['name'])]
        rescue RuntimeError
          not_found
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

      get %r{/(edit|create)/(\.redirects.gollum|(custom|math\.config)\.(js|css))} do
        forbid('Changing this resource is not allowed.')
      end

      post %r{/(delete|rename|edit|create)/(\.redirects.gollum|(custom|math\.config)\.(js|css))} do
        forbid('Changing this resource is not allowed.')
      end

      post %r{/revert/(\.redirects.gollum|(custom|math\.config\.)\.(js|css)/.*/.*)} do
        forbid('Changing this resource is not allowed.')
      end

      get '/edit/*' do
        forbid unless @allow_editing
        wikip = wiki_page(params[:splat].first)
        @name = wikip.fullname
        @path = wikip.path
        @upload_dest = find_upload_dest(wikip.fullpath)
        wiki = wikip.wiki
        @allow_uploads = wiki.allow_uploads
          if page = wikip.page
              @page         = page
              @content      = page.text_data
              @etag         = page.sha
              mustache :edit
          else
            path = ::File.join('gollum/create', @path, @name)
            redirect to(clean_url(encodeURIComponent(path)))
          end
        end

      # AJAX calls only
      post '/upload_file' do

        wiki = wiki_new
        halt 405 unless wiki.allow_uploads

        if params[:file]
          fullname = params[:file][:filename]
          tempfile = params[:file][:tempfile]
        end
        halt 500 unless tempfile.is_a? Tempfile
        
        dir = wiki.per_page_uploads ? find_per_page_upload_subdir(request.referer, request.host_with_port, wiki.base_path) : 'uploads'

        halt 500 if dir.include?('..')
        halt 500 unless Pathname(dir).relative?

        ext      = ::File.extname(fullname)
        format   = ext.split('.').last || 'txt'
        filename = ::File.basename(fullname, ext)
        contents = ::File.read(tempfile)
        reponame = "#{dir}/#{filename}.#{format}"

        options = { :message => "Uploaded file to #{reponame}" }
        options[:parent] = wiki.repo.head.commit if wiki.repo.head

        author  = session['gollum.author']
        unless author.nil?
          options.merge! author
        end

        options[:normalize] = Gollum::Page.valid_extension?(fullname)

        begin
          wiki.write_file(reponame, contents, options)
          redirect to(request.referer)
        rescue Gollum::IllegalDirectoryPath => e
          @message = e.message
          mustache :error
        rescue Gollum::DuplicatePageError
          halt 409, "The file you are trying to upload already exists." # Signal conflict
        end
      end


      post '/rename/*' do
        wikip = wiki_page(params[:splat].first)
        halt 500 if wikip.nil?
        wiki   = wikip.wiki
        page   = wikip.page
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

        committer = Gollum::Committer.new(wiki, commit_options)
        commit    = { :committer => committer }

        success = wiki.rename_page(page, rename, commit)
        if !success
          # This occurs on NOOPs, for example renaming A => A
          redirect to("/#{page.escaped_url_path}")
          return
        end

        # Renaming preserves format, so add the page's format to the renamed path to retrieve the renamed page
        new_path = "#{rename}.#{Gollum::Page.format_to_ext(page.format)}"
        # Add a redirect from the old page to the new
        wiki.add_redirect(page.url_path, clean_url(new_path), commit) if @redirects_enabled

        committer.commit

        page = wiki_page(new_path).page
        return if page.nil?
        redirect to("/#{page.escaped_url_path}")
      end

      post '/edit/*' do
        etag      = params[:etag]
        path      = "/#{clean_url(sanitize_empty_params(params[:path]))}"
        wiki      = wiki_new
        page      = wiki.page(::File.join(path, params[:page]))

        return if page.nil?
        if etag != page.sha
          # Signal edit collision and return the page's most recent version
          halt 412, {etag: page.sha, text_data: page.text_data}.to_json
        end

        begin
        committer = Gollum::Committer.new(wiki, commit_options)
        commit    = { :committer => committer }

        update_wiki_page(wiki, page, params[:content], commit, page.name, params[:format])
        update_wiki_page(wiki, page.header, params[:header], commit) if params[:header]
        update_wiki_page(wiki, page.footer, params[:footer], commit) if params[:footer]
        update_wiki_page(wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
        committer.commit
        rescue Gollum::DuplicatePageError
          halt 409, "You are trying to save this page under a path (#{page.escaped_url_path}) that already exists." # Signal conflict
        end

      end

      post '/delete/*' do
        forbid unless @allow_editing
        wiki = wiki_new
        filepath = params[:splat].first
        unless filepath.nil?
          commit           = commit_options
          commit[:message] = "Deleted #{filepath}"
          wiki.delete_file(filepath, commit)
        end
      end

      get '/create/*' do
        forbid unless @allow_editing
        wikip = wiki_page(params[:splat].first)
        @name = wikip.name
        @ext  = wikip.ext
        @path = wikip.path
        @template_page = load_template(wikip, @path) if settings.wiki_options[:template_page]
        @allow_uploads = wikip.wiki.allow_uploads
        @upload_dest   = find_upload_dest(wikip.fullpath)

        page = wikip.page
        if page
          redirect to("/#{clean_url(page.escaped_url_path)}")
        else
          unless Gollum::Page.format_for("#{@name}#{@ext}")
            @name = "#{@name}#{@ext}"
            @ext = nil
          end
          mustache :create
        end
      end

      post '/create' do
        name   = params[:page]
        path   = sanitize_empty_params(params[:path]) || ''
        format = params[:format].intern
        wiki   = wiki_new

        path.gsub!(/^\//, '')

        begin
          wiki.write_page(::File.join(path, name), format, params[:content], commit_options)

          redirect to("/#{clean_url(::File.join(encodeURIComponent(path), encodeURIComponent(wiki.page_file_name(name, format))))}")
        rescue Gollum::DuplicatePageError, Gollum::IllegalDirectoryPath => e
          @message = e.message
          mustache :error
        end
      end

      post '/revert/*/:sha1/:sha2' do
        wikip = wiki_page(params[:splat].first)
        @path = wikip.path
        @name = wikip.fullname
        wiki  = wikip.wiki
        @page = wikip.page
        sha1  = params[:sha1]
        sha2  = params[:sha2]

        commit           = commit_options
        commit[:message] = "Revert commit #{sha2.chars.take(7).join}"
        if wiki.revert_page(@page, sha1, sha2, commit)
          redirect to("/#{@page.escaped_url_path}")
        else
          sha2, sha1 = sha1, "#{sha1}^" if !sha2
          @versions  = [sha1, sha2]
          @diff      = wiki.repo.diff(@versions.first, @versions.last, @page.path)
          @message   = 'The patch does not apply.'
          mustache :compare
        end
      end

      post '/preview' do
        wiki           = wiki_new
        @name          = params[:page] ? strip_page_name(params[:page]) : 'Preview'
        @page          = wiki.preview_page(@name, params[:content], params[:format])
        ['sidebar', 'header', 'footer'].each do |subpage|
          @page.send("set_#{subpage}".to_sym, params[subpage]) if params[subpage]
        end
        @content       = @page.formatted_data
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @h1_title      = wiki.h1_title
        @editable      = false
        @bar_side      = wiki.bar_side
        @allow_uploads = false
        @navbar        = false
        @preview       = true
        mustache :page
      end

      get %r{
        /history/             # match any URL beginning with /history/
        (.+?)                 # extract the full path (including any directories)
        /
        ([0-9a-f]{40})        # match SHA
      }x do |path, version|
        wiki = wiki_new
        show_history wiki_page(path, version, wiki)
      end

      get '/history/*' do
        show_history wiki_page(params[:splat].first)
      end

      get '/latest_changes' do
        @wiki = wiki_new
        @page_num = [params[:page_num].to_i, 1].max
        @max_count = settings.wiki_options.fetch(:pagination_count, 10)
        @versions = @wiki.latest_changes(::Gollum::Page.log_pagination_options(per_page: @max_count, page_num: @page_num))
        mustache :latest_changes
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
        @name     = wikip.fullname
        @versions = [start_version, end_version]
        wiki      = wikip.wiki
        @page     = wikip.page
        @diff     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
        if @diff.empty?
          @message = 'Could not compare these two revisions, no differences were found.'
          mustache :error
        else
          mustache :compare
        end
      end

      get '/compare/*' do
        @file     = clean_url(encodeURIComponent(params[:splat].first))
        @versions = params[:versions] || []
        if @versions.size == 1
          wikip  = wiki_page(params[:splat].first)
          commit = wikip.wiki.repo.commit(@versions.first)
          parent = commit.parent
          if parent.nil?
            redirect to("#{@file}/#{@commit.id}")
          else
            @versions.push(parent.id)
          end
        end
        if @versions.empty?
          redirect to("gollum/history/#{@file}")
        else
          redirect to("gollum/compare/%s/%s...%s" % [
              @file,
              @versions.last,
              @versions.first]
                   )
        end
      end


      get %r{
        /commit/  # match any URL beginning with /show/
        (\w+)     # match the SHA1
      }x do |version|
        @version = version
        wiki = wiki_new
        begin
          @commit = wiki.repo.commit(version)
          parent = @commit.parent
          parent_id = parent.nil? ? nil : parent.id
          @diff = wiki.repo.diff(parent_id, version)
          mustache :commit
        rescue Gollum::Git::NoSuchShaFound
          @message = "Invalid commit: #{@version}"
          mustache :error
        end
      end

      get '/search' do
        @query     = params[:q] || ''
        @name      = @query
        if @query.empty?
          @results = []
          @search_terms = []
        else
          @page_num  = [params[:page_num].to_i, 1].max
          @max_count = 10
          wiki       = wiki_new
          @results, @search_terms = wiki.search(@query)
        end
        mustache :search
      end

      get %r{
        /overview  # match any URL beginning with /overview
        (?:     # begin an optional non-capturing group
          /(.+) # capture any path after the "/overview" excluding the leading slash
        )?      # end the optional non-capturing group
      }x do |path|
        wiki         = wiki_new
        @results     = wiki.tree_list

        if path
          @path = Pathname.new(path).cleanpath.to_s
          check_path   = wiki.page_file_dir ? ::File.join(wiki.page_file_dir, @path, '/') : "#{@path}/"
          @results.select!  {|result| result.path.start_with?(check_path) }
        end

        @results.sort_by! {|result| result.name.downcase}

        @ref         = wiki.ref
        @newable     = true
        mustache :overview
      end
    end # gollum namespace

    get %r{/(.+?)/([0-9a-f]{40})} do
      file_path = params[:captures][0]
      version   = params[:captures][1]
      wikip     = wiki_page(file_path, version)
      name      = wikip.fullname
      path      = wikip.path
      if page = wikip.page
        @page    = page
        @name    = name
        @content = page.formatted_data
        @version = version
        @historical = true
        @bar_side = wikip.wiki.bar_side
        @navbar   = true
        mustache :page
      elsif file = wikip.wiki.file(file_path, version, true)
        show_file(file)
      else
        halt 404
      end
    end

    get '/\.redirects\.gollum' do
      forbid('Accessing this resource is not allowed.')
    end

    get '/*' do
      fullpath = params[:splat].first
      if params.has_key?("raw")
        show_raw_page(fullpath)
      else
        show_page_or_file(fullpath)
      end
    end

    private

    def redirect_to(redirect_path, fullpath, query_params)
        redirect to("#{encodeURI(redirect_path)}?redirected_from=#{encodeURI(fullpath)}#{query_params}")
    end

    def page_does_not_exist()
      @message = "The requested page does not exist."
      status 404
      return mustache :error
    end

    def show_history(wikip)
      @name      = wikip.fullname
      @page      = wikip.page
      @page_num  = [params[:page_num].to_i, 1].max
      @max_count = settings.wiki_options.fetch(:pagination_count, 10)
      unless @page.nil?
        @wiki     = @page.wiki
        @versions = @page.versions(
          per_page: @max_count,
          page_num: @page_num,
          follow: settings.wiki_options.fetch(:follow_renames, true)
        )
        mustache :history
      else
        redirect to("/")
      end
    end

    def show_page_or_file(fullpath)
      wiki = wiki_new
      if page = wiki.page(fullpath)
        @page          = page
        @name          = page.filename_stripped
        @content       = page.formatted_data
        @upload_dest   = find_upload_dest(Pathname.new(fullpath).cleanpath.to_s)

        # Extensions and layout data
        @editable      = true
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @h1_title      = wiki.h1_title
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads
        @navbar        = true
        mustache :page
      elsif file = wiki.file(fullpath, wiki.ref, true)
        show_file(file)
      elsif @redirects_enabled && redirect_path = wiki.redirects[fullpath]
        redirect_to(redirect_path, fullpath, "")
      else
        if @allow_editing
          path = fullpath[-1] == '/' ? "#{fullpath}#{wiki.index_page}" : fullpath # Append default index page if no page name is supplied
          redirect to("/gollum/create/#{clean_url(encodeURIComponent(path))}")
        else
          return page_does_not_exist
        end
      end
    end

    def show_raw_page(fullpath)
      wiki = wiki_new
      if @redirects_enabled && redirect_path = wiki.redirects[fullpath]
        redirect_to(redirect_path, fullpath, "&raw")
      elsif page = wiki.page(fullpath) and file = wiki.file(fullpath, wiki.ref, true)
        show_file(file)
      else
        return page_does_not_exist
      end
    end

    def show_file(file)
      return unless file
      content_type file.mime_type
      if file.on_disk?
        send_file file.on_disk_path, :disposition => 'inline'
      else
        file.raw_data
      end
    end

    def load_template(wiki_page, path)
      template_page = wiki_page(::File.join(path, '_Template')).page || wiki_page('/_Template').page
      template_page ? Gollum::TemplateFilter.apply_filters(wiki_page, template_page.text_data) : nil
    end

    def update_wiki_page(wiki, page, content, commit, name = nil, format = nil)
      return if !page ||
          ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format  = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit)
    end

    def wiki_page(path, version = nil, wiki = nil)
      pathname = (Pathname.new('/') + path).cleanpath
      wiki = wiki_new if wiki.nil?
      OpenStruct.new(:wiki => wiki, :page => wiki.page(pathname.to_s, version = version),
                     :name => pathname.basename.sub_ext('').to_s, :path => pathname.dirname.to_s, :ext => pathname.extname, :fullname => pathname.basename.to_s, :fullpath => pathname.to_s)
    end

    def wiki_new
      Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    end

    # Options parameter to Gollum::Committer#initialize
    #     :message   - The String commit message.
    #     :name      - The String author full name.
    #     :email     - The String email address.
    # message is sourced from the incoming request parameters
    # optional author details are sourced from the session, to be populated by rack middleware ahead of us.
    # optional note is equally sourced from the session.
    def commit_options
      msg               = (params[:message].nil? or params[:message].empty?) ? "[no message]" : params[:message]
      commit_options    = { message: msg, note: session['gollum.note'] }
      author_parameters = session['gollum.author']
      commit_options.merge! author_parameters unless author_parameters.nil?
      commit_options
    end

    def find_upload_dest(path)
      settings.wiki_options[:allow_uploads] ?
          (settings.wiki_options[:per_page_uploads] ?
              path : 'uploads'
          ) : ''
    end

  end
end
