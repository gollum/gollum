# ~*~ encoding: utf-8 ~*~
require 'cgi'
require 'sinatra'
require 'gollum-lib'
require 'mustache/sinatra'
require 'useragent'
require 'stringex'
require 'sqlite3'

require 'gollum'
require 'gollum/views/layout'
require 'gollum/views/editable'
require 'gollum/views/has_page'

require 'gollum/views/admin_page'

require File.expand_path '../helpers', __FILE__

#required to upload bigger binary files
Gollum::set_git_timeout(120)
Gollum::set_git_max_filesize(190 * 10**6)

# Fix to_url
class String
  alias :upstream_to_url :to_url
  # _Header => header which causes errors
  def to_url
    return nil if self.nil?
    upstream_to_url :exclude => ['_Header', '_Footer', '_Sidebar'], :force_downcase => false
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
    include Precious::Helpers

    dir     = File.dirname(File.expand_path(__FILE__))

    # Detect unsupported browsers.
    Browser = Struct.new(:browser, :version)

    @@min_ua = [
        Browser.new('Internet Explorer', '10.0'),
        Browser.new('Chrome', '7.0'),
        Browser.new('Firefox', '4.0'),
    ]

    def supported_useragent?(user_agent)
      ua = UserAgent.parse(user_agent)
      @@min_ua.detect { |min| ua >= min }
    end

    # We want to serve public assets for now
    set :public_folder, "#{dir}/public/gollum"
    set :static, true
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
      enable :raise_errors, :dump_errors
    end

    before do
      @base_url = url('/', false).chomp('/')
      # above will detect base_path when it's used with map in a config.ru
      settings.wiki_options.merge!({ :base_path => @base_url })
      @css = settings.wiki_options[:css]
      @js  = settings.wiki_options[:js]
    end

    get '/admin' do
      db = SQLite3::Database.open "weaki_v2.db"
      # @result = db.execute "SELECT DISTINCT Users.email, Roles.type FROM Users INNER JOIN UsersRoles ON Users.email=UsersRoles.email INNER JOIN Roles ON UsersRoles.type=Roles.type;"
      # p @result
      # @result = @result.first
      @users = get_users_from_db
      @roles = get_roles_from_db
      db.close
      mustache :admin_page
    end

    post '/admin' do
      # puts params[:email]
      if params[:action] == "check_user"
        unless params[:remove].nil?
          user = params[:user]
          delete_user user
          @success = "User #{user} successfully deleted!"
        else
          @selected_user = params[:user]
          @user_roles = get_user_roles @selected_user
        end
      elsif params[:action] == "check_role"
        @selected_role = params[:role]
        @role_perms = get_role_permissions @selected_role
      elsif params[:action] == "add_user"
        add_email_to_db params[:user]
        @success = "User successfully added!"
      elsif params[:action] == "remove_perms"
        remove_perms_by_id params[:id]
        @success = "Permissions successfully removed!"
      elsif params[:action] == "remove_role_from_user"
        user = params[:user]
        role = params[:role]
        remove_role_from_user(user,role)
        @selected_user = user
        @user_roles = get_user_roles @selected_user
      elsif params[:action] == "add_perms_to_role"
        # add permissions to role
        # add_perms_to_role params[:selected_role], params[:regex], params[:crud]
        role = params[:selected_role]
        regex = params[:regex]
        crud = params[:crud]
        add_perms_to_role(role, regex, crud)
      elsif params[:action] == "add_role_to_user"
        user = params[:user]
        role = params[:role]
        add_role_to_user(user, role)
        @selected_user = user
        @user_roles = get_user_roles @selected_user
      end

      @users = get_users_from_db
      @roles = get_roles_from_db
      mustache :admin_page
      # redirect '/'
    end

    get '/' do
      page_dir = settings.wiki_options[:page_file_dir].to_s
      redirect clean_url(::File.join(@base_url, page_dir, wiki_new.index_page))
    end

    # path is set to name if path is nil.
    #   if path is 'a/b' and a and b are dirs, then
    #   path must have a trailing slash 'a/b/' or
    #   extract_path will trim path to 'a'
    # name, path, version
    def wiki_page(name, path = nil, version = nil, exact = true)
      wiki = wiki_new

      path = name if path.nil?
      name = extract_name(name) || wiki.index_page
      path = extract_path(path)
      path = '/' if exact && path.nil?

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
          @page         = page
          @page.version = wiki.repo.log(wiki.ref, @page.path).first
          @content      = page.text_data
          mustache :edit
        end
      else
        redirect to("/create/#{encodeURIComponent(@name)}")
      end
    end

    post '/uploadFile' do
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

      dir      = wiki.per_page_uploads ? params[:upload_dest] : 'uploads'
      ext      = ::File.extname(fullname)
      format   = ext.split('.').last || 'txt'
      filename = ::File.basename(fullname, ext)
      contents = ::File.read(tempfile)
      reponame = filename + '.' + format

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
      page   = wiki.paged(wikip.name, wikip.path, exact = true)
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
      page  = wiki.paged(wikip.name, wikip.path, exact = true)
      return if page.nil?
      redirect to("/#{page.escaped_url_path}")
    end

    post '/edit/*' do
      path      = '/' + clean_url(sanitize_empty_params(params[:path])).to_s
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

    get '/delete/*' do
      wikip = wiki_page(params[:splat].first)
      name  = wikip.name
      wiki  = wikip.wiki
      page  = wikip.page
      unless page.nil?
        wiki.delete_page(page, { :message => "Destroyed #{name} (#{page.format})" })
      end

      redirect to('/')
    end

    get '/create/*' do
      wikip = wiki_page(params[:splat].first.gsub('+', '-'))
      @name = wikip.name.to_url
      @path = wikip.path

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
        redirect to("/#{clean_url(::File.join(page_dir, path, name))}")
      rescue Gollum::DuplicatePageError => e
        @message = "Duplicate page: #{e.message}"
        mustache :error
      end
    end

    post '/revert/*/:sha1/:sha2' do
      wikip = wiki_page(params[:splat].first)
      @path = wikip.path
      @name = wikip.name
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
      @allow_uploads = wiki.allow_uploads
      mustache :page
    end

    get '/history_all' do
      wiki = wiki_new
      pages = wiki.pages
      @versions = Array.new
      pages.each { |p|
        page_versions = p.versions
        page_versions.each { |v|
          temp = [v, p]
          @versions.push temp
        }
      }
      mustache :history_all
    end

    get '/history/*' do
      @page     = wiki_page(params[:splat].first).page
      @page_num = [params[:page].to_i, 1].max
      unless @page.nil?
        @versions = @page.versions :page => @page_num
        mustache :history
      else
        redirect to("/")
      end
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
      wikip     = wiki_page(path)
      @path     = wikip.path
      @name     = wikip.name
      @versions = [start_version, end_version]
      wiki      = wikip.wiki
      @page     = wikip.page
      diffs     = wiki.repo.diff(@versions.first, @versions.last, @page.path)
      @diff     = diffs.first
      mustache :compare
    end

    get %r{/(.+?)/([0-9a-f]{40})} do
      file_path = params[:captures][0]
      version   = params[:captures][1]
      wikip     = wiki_page(file_path, file_path, version)
      name      = wikip.name
      path      = wikip.path
      if page = wikip.page
        @page    = page
        @name    = name
        @content = page.formatted_data
        @version = version
        mustache :page
      else
        halt 404
      end
    end

    get '/search' do
      @query   = params[:q]
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
      @results     += wiki.files if settings.wiki_options[:show_all]
      @ref         = wiki.ref
      mustache :pages
    end

    get '/fileview' do
      wiki     = wiki_new
      options  = settings.wiki_options
      content  = wiki.pages
      # if showing all files include wiki.files
      content  += wiki.files if options[:show_all]

      # must pass wiki_options to FileView
      # --show-all and --collapse-tree can be set.
      @results = Gollum::FileView.new(content, options).render_files
      @ref     = wiki.ref
      mustache :file_view, { :layout => false }
    end

    get '/*' do
      show_page_or_file(params[:splat].first)
    end

    def show_page_or_file(fullpath)
      wiki = wiki_new

      name = extract_name(fullpath) || wiki.index_page
      path = extract_path(fullpath) || '/'

      if page = wiki.paged(name, path, exact = true)
        @page          = page
        @name          = name
        @content       = page.formatted_data
        @upload_dest   = settings.wiki_options[:allow_uploads] ?
            (settings.wiki_options[:per_page_uploads] ?
                "#{path}/#{@name}".sub(/^\/\//, '') : 'uploads'
            ) : ''

        # Extensions and layout data
        @editable      = true
        @page_exists   = !page.versions.empty?
        @toc_content   = wiki.universal_toc ? @page.toc_data : nil
        @mathjax       = wiki.mathjax
        @h1_title      = wiki.h1_title
        @bar_side      = wiki.bar_side
        @allow_uploads = wiki.allow_uploads

        mustache :page
      elsif file = wiki.file(fullpath, wiki.ref, true)
        if file.on_disk?
          send_file file.on_disk_path, :disposition => 'inline'
        else
          content_type file.mime_type
          file.raw_data
        end
      else
        page_path = [path, name].compact.join('/')
        redirect to("/create/#{clean_url(encodeURIComponent(page_path))}")
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

    private

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

    def get_users_from_db
      db = SQLite3::Database.open "weaki_v2.db"
      results = db.execute "select Users.email from Users;"
      db.close
      return results
    end

    def get_permissions_of_user(email)
      db = SQLite3::Database.open "weaki_v2.db"
      results = db.execute "select Roles.name, Roles.regex, Roles.crud from Users INNER JOIN UsersRoles ON Users.email=UsersRoles.email INNER JOIN Roles ON UsersRoles.role=Roles.name WHERE Users.email = ? ;", email
      db.close
      return results
    end

    def get_user_roles(email)
      db = SQLite3::Database.open "weaki_v2.db"
      results = db.execute "select UsersRoles.role from Users inner join UsersRoles on Users.email=UsersRoles.email where Users.email = ?", email
      db.close
      return results
    end

    def get_roles_from_db
      db = SQLite3::Database.open "weaki_v2.db"
      results = db.execute "select distinct Roles.name from Roles;"
      db.close
      return results
    end

    def get_role_permissions(role)
      db = SQLite3::Database.open "weaki_v2.db"
      db.results_as_hash = true
      results = db.execute "select Roles. id, Roles.regex, Roles.crud from Roles where Roles.name = ?", role
      db.close
      return results
    end

    def add_email_to_db(email)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        db.execute "insert into Users values(?);", email
      rescue SQLite3::Exception => e
        puts "Error adding email #{email}"
        p e
      ensure
        db.close if db
      end
    end

    def remove_perms_by_id(id)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        db.execute "delete from Roles where Roles.id = ?", id
      rescue SQLite3::Exception => e
        p e
      ensure
        db.close if db
      end
    end

    def add_perms_to_role(role, regex, crud)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        stm = db.prepare "insert into Roles values (NULL, ?, ?, ?)"
        stm.bind_params role, regex, crud
        stm.execute
      rescue SQLite3::Exception => e
        @message = "Error adding permissions to role #{role}: #{e.message}"
      ensure
        stm.close if stm
        db.close if db
      end
    end

    def delete_user(user)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        stm = db.prepare "delete from Users where email = :user"
        stm.execute user
        stm2 = db.prepare "delete from UsersRoles where email = :user"
        stm2.execute user
      rescue SQLite3::Exception => e
        @message = "Error deleting user #{user}: #{e.message}"
        mustache :error
      ensure
        stm.close if stm
        stm2.close if stm
        db.close if db
      end
    end

    def add_role_to_user(user, role)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        stm = db.prepare "insert into UsersRoles values(?,?)"
        stm.bind_params user, role
        stm.execute
      rescue SQLite3::Exception => e
        @message = "Error adding role to #{user}: #{e.message}"
        mustache :error
      ensure
        stm.close if stm
        db.close if db
      end
    end

    def remove_role_from_user(user, role)
      begin
        db = SQLite3::Database.open "weaki_v2.db"
        stm = db.prepare "delete from UsersRoles where email = ? and role = ?"
        stm.bind_params user, role
        stm.execute
      rescue SQLite3::Exception => e
        @message = "Error removing role from user #{user}: #{e.message}"
      ensure
        stm.close if stm
        db.close if db
      end
    end
  end
end
