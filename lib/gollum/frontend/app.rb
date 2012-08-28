require 'cgi'
require 'sinatra'
require 'gollum'
require 'mustache/sinatra'
require 'useragent'
require 'stringex'

require 'gollum/frontend/views/layout'
require 'gollum/frontend/views/editable'
require 'gollum/frontend/views/has_page'

require File.expand_path '../helpers', __FILE__

# Fix to_url
class String
  alias :upstream_to_url :to_url
  # _Header => header which causes errors
  def to_url
    return nil if self.nil?
    return self if ['_Header', '_Footer', '_Sidebar'].include? self
    upstream_to_url
  end
end

# Run the frontend, based on Sinatra
#
# There are a number of wiki options that can be set for the frontend
#
# Example
# require 'gollum/frontend/app'
# Precious::App.set(:wiki_options, {
#     :universal_toc => false,
# }
#
# See the wiki.rb file for more details on wiki options
module Precious
  class App < Sinatra::Base
    register Mustache::Sinatra
    include Precious::Helpers

    dir = File.dirname(File.expand_path(__FILE__))

    # Detect unsupported browsers.
    Browser = Struct.new(:browser, :version)

    @@min_ua = [
        Browser.new('Internet Explorer', '10.0'),
        Browser.new('Chrome', '7.0'),
        Browser.new('Firefox', '4.0'),
    ]

    def supported_useragent?(user_agent)
      ua = UserAgent.parse(user_agent)
      @@min_ua.detect {|min| ua >= min }
    end

    # We want to serve public assets for now
    set :public_folder, "#{dir}/public/gollum"
    set :static,         true
    set :default_markup, :markdown

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

    before do
      @base_url = url('/', false).chomp('/')
      settings.wiki_options.merge!({ :base_path => @base_url }) unless settings.wiki_options.has_key? :base_path
    end

    get '/' do
      redirect File.join(settings.wiki_options[:base_path].to_s, 'Home')
    end

    # Removes all slashes from the start of string.
    def clean_url url
      return url if url.nil?
      url.gsub('%2F','/').gsub(/^\/+/,'')
    end

    # path is set to name if path is nil.
    #   if path is 'a/b' and a and b are dirs, then
    #   path must have a trailing slash 'a/b/' or
    #   extract_path will trim path to 'a'
    # name, path, version
    def wiki_page(name, path = nil, version = nil, exact = true)
      path = name if path.nil?
      name = extract_name(name)
      path = extract_path(path)
      path = '/' if exact && path.nil?

      wiki = wiki_new

      OpenStruct.new(:wiki => wiki, :page => wiki.paged(name, path, exact, version),
                     :name => name, :path => path)
    end

    def wiki_new
      Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
    end

    get '/data/*' do
      if page = wiki_page(params[:splat].first).page
        page.raw_data
      end
    end

    get '/edit/*' do
      wikip = wiki_page(params[:splat].first)
      @name = wikip.name
      @path = wikip.path
      wiki = wikip.wiki
      if page = wikip.page
        if wiki.live_preview && page.format.to_s.include?('markdown') && supported_useragent?(request.user_agent)
          live_preview_url = '/livepreview/index.html?page=' + encodeURIComponent(@name)
          if @path
            live_preview_url << '&path=' + encodeURIComponent(@path)
          end
          redirect to(live_preview_url)
        else
          @page = page
          @page.version = wiki.repo.log(wiki.ref, @page.path).first
          raw_data = page.raw_data
          @content = raw_data.respond_to?(:force_encoding) ? raw_data.force_encoding('UTF-8') : raw_data
          mustache :edit
        end
      else
        redirect to("/create/#{encodeURIComponent(@name)}")
      end
    end

    post '/edit/*' do
      path      = '/' + clean_url(sanitize_empty_params(params[:path])).to_s
      page_name = CGI.unescape(params[:page])
      wiki      = wiki_new
      page      = wiki.paged(page_name, path, exact = true)
      rename    = params[:rename].to_url if params[:rename]
      name      = rename || page.name
      committer = Gollum::Committer.new(wiki, commit_message)
      commit    = {:committer => committer}

      update_wiki_page(wiki, page, params[:content], commit, name, params[:format])
      update_wiki_page(wiki, page.header,  params[:header],  commit) if params[:header]
      update_wiki_page(wiki, page.footer,  params[:footer],  commit) if params[:footer]
      update_wiki_page(wiki, page.sidebar, params[:sidebar], commit) if params[:sidebar]
      committer.commit

      page = wiki.page(rename) if rename

      redirect to("/#{page.escaped_url_path}") unless page.nil?
    end

    get '/delete/*' do
      wikip = wiki_page(params[:splat].first)
      name = wikip.name
      wiki = wikip.wiki
      page = wikip.page
      wiki.delete_page(page, { :message => "Destroyed #{name} (#{page.format})" })

      redirect to('/')
    end

    get '/create/*' do
      wikip = wiki_page(params[:splat].first.gsub('+', '-'))
      @name = wikip.name.to_url
      @path = wikip.path

      page = wikip.page
      if page
        redirect to("/#{page.escaped_url_path}")
      else
        mustache :create
      end
    end

    post '/create' do
      name         = params[:page].to_url
      path         = sanitize_empty_params(params[:path])
      path = '' if path.nil?
      format       = params[:format].intern

      # write_page is not directory aware so use wiki_options to emulate dir support.
      wiki_options = settings.wiki_options.merge({ :page_file_dir => path })
      wiki         = Gollum::Wiki.new(settings.gollum_path, wiki_options)

      begin
        wiki.write_page(name, format, params[:content], commit_message)
        redirect to("/#{clean_url(CGI.escape(::File.join(path,name)))}")
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/:page/*' do
      wikip        = wiki_page(params[:page])
      @path        = wikip.path
      @name        = wikip.name
      wiki         = wikip.wiki
      @page        = wiki.paged(@name,@path)
      shas         = params[:splat].first.split("/")
      sha1         = shas.shift
      sha2         = shas.shift

      if wiki.revert_page(@page, sha1, sha2, commit_message)
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
      wiki     = wiki_new
      @name    = params[:page] || "Preview"
      @page    = wiki.preview_page(@name, params[:content], params[:format])
      @content = @page.formatted_data
      @toc_content = wiki.universal_toc ? @page.toc_data : nil
      @mathjax = wiki.mathjax
      @editable = false
      mustache :page
    end

    get '/history/*' do
      @page        = wiki_page(params[:splat].first).page
      @page_num    = [params[:page].to_i, 1].max
      @versions    = @page.versions :page => @page_num
      mustache :history
    end

    post '/compare/*' do
      @file     = params[:splat].first
      @versions = params[:versions] || []
      if @versions.size < 2
        redirect to("/history/#{@file}")
      else
        redirect to("/compare/%s/%s...%s" % [
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
      wikip        = wiki_page(path)
      @path        = wikip.path
      @name        = wikip.name
      @versions    = [start_version, end_version]
      wiki         = wikip.wiki
      @page        = wikip.page
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
      file_path = params[:captures][0]
      version   = params[:captures][1]
      wikip     = wiki_page(file_path, file_path, version)
      name      = wikip.name
      path      = wikip.path
      if page = wikip.page
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
      wiki = wiki_new
      @results = wiki.search @query
      @name = @query
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
      @ref         = wiki.ref
      mustache :pages
    end

    get '/fileview' do
      wiki = Gollum::Wiki.new(settings.gollum_path, settings.wiki_options)
      @results = Gollum::FileView.new(wiki.pages).render_files
      @ref = wiki.ref
      mustache :file_view, { :layout => false }
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(fullpath)
      name         = extract_name(fullpath)
      path         = extract_path(fullpath)
      wiki         = wiki_new

      path = '/' if path.nil?

      if page = wiki.paged(name, path, exact = true)
        @page = page
        @name = name
        @editable = true
        @content = page.formatted_data
        @toc_content = wiki.universal_toc ? @page.toc_data : nil
        @mathjax = wiki.mathjax
        mustache :page
      elsif file = wiki.file(fullpath)
        content_type file.mime_type
        file.raw_data
      else
        page_path = [path, name].compact.join('/')
        redirect to("/create/#{clean_url(encodeURIComponent(page_path))}")
      end
    end

    def update_wiki_page(wiki, page, content, commit, name = nil, format = nil)
      return if !page ||
        ((!content || page.raw_data == content) && page.format == format)
      name    ||= page.name
      format    = (format || page.format).to_sym
      content ||= page.raw_data
      wiki.update_page(page, name, format, content.to_s, commit)
    end

    def commit_message
      { :message => params[:message] }
    end
  end
end
