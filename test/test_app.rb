# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Frontend" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath("examples/revert.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {})
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "urls transform unicode" do
    header = '_Header'
    footer = '_Footer'
    sidebar = '_Sidebar'

    # header, footer, and sidebar must be preserved
    # or gollum will not recognize them
    assert_equal header, header.to_url
    assert_equal footer, footer.to_url
    assert_equal sidebar, sidebar.to_url

    # spaces are converted to dashes in URLs
    # and in file names saved to disk
    # urls are not case sensitive
    assert_equal 'title-space', 'Title Space'.to_url

    # ascii only file names prevent UTF8 issues
    # when using git repos across operating systems
    # as this test demonstrates, translation is not
    # great
    assert_equal 'm-plus-f', 'μ†ℱ'.to_url
  end

  test "utf-8 kcode" do
    assert_equal 'μ†ℱ'.scan(/./), ["μ", "†", "ℱ"]
  end


  test "broken four space" do
    page = 'utfh1'
    text = %(
    one
    two
    three
    four
)

    @wiki.write_page(page, :markdown, text,
                     { :name => 'user1', :email => 'user1' });

    get page
    # good html:
    # <pre><code>one\ntwo\nthree\nfour\n</code></pre>\n
    # broken html:
    # <pre>\n  <code>one\ntwo\nthree\nfour\n</code>\n</pre>
    assert_match /<pre><code>one\ntwo\nthree\nfour\n<\/code><\/pre>\n/m, last_response.body
  end

  test "UTF-8 headers href preserved" do
    page = 'utfh1'
    text = '한글'

    # don't use h1 or it will be promoted to replace file name
    # which doesn't generate a normal header link
    @wiki.write_page(page, :markdown, '## ' + text,
                     { :name => 'user1', :email => 'user1' });

    get page

    assert_match /<h2>#{text}<a class="anchor" id="#{text}" href="##{text}"><\/a><\/h2>/, last_response.body
  end

  test "retain edit information" do
    page1 = 'page1'
    user1 = 'user1'
    @wiki.write_page(page1, :markdown, '',
                     { :name => user1, :email => user1 });

    get page1
    assert_match /Last edited by <b>user1/, last_response.body

    page2 = 'page2'
    user2 = 'user2'
    @wiki.write_page(page2, :markdown, '',
                     { :name => user2, :email => user2 });

    get page2
    assert_match /Last edited by <b>user2/, last_response.body

    get page1
    assert_match /Last edited by <b>user1/, last_response.body
  end

  test "edits page" do
    page_1 = @wiki.page('A')
    post "/edit/A", :content => 'abc', :page => 'A',
      :format => page_1.format, :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    assert_equal 'abc', page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "edit page with empty message" do
    page_1 = @wiki.page('A')
    post "/edit/A", :content => 'abc', :page => 'A',
      :format => page_1.format
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    assert_equal 'abc', page_2.raw_data
    assert_equal '[no message]', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "edit page with slash" do
    page_1 = @wiki.page('A')
    post "/edit/A", :content => 'abc', :page => 'A', :path => '/////',
      :format => page_1.format, :message => 'def'
    follow_redirect!
    assert last_response.ok?
  end

  test "edits page header footer and sidebar" do
    commits = @wiki.repo.commits('master').size
    page_1  = @wiki.page('A')
    header_1 = page_1.header
    foot_1  = page_1.footer
    side_1  = page_1.sidebar

    post "/edit/A", :header => 'header',
      :footer => 'footer', :page => "A", :sidebar => 'sidebar', :message => 'def'
    follow_redirect!
    assert_equal "/A", last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    header_2 = page_2.header
    foot_2 = page_2.footer
    side_2 = page_2.sidebar
    assert_equal page_1.raw_data, page_2.raw_data

    assert_equal 'header', header_2.raw_data
    assert_equal 'footer', foot_2.raw_data
    assert_equal 'def',    foot_2.version.message
    assert_not_equal foot_1.version.sha, foot_2.version.sha
    assert_not_equal header_1.version.sha, header_2.version.sha

    assert_equal 'sidebar', side_2.raw_data
    assert_equal 'def',     side_2.version.message
    assert_not_equal side_1.version.sha, side_2.version.sha
    assert_equal commits+1, @wiki.repo.commits('master').size
  end

  test "renames page" do
    page_1 = @wiki.page("B")
    post "/rename/B", :rename => "/C", :message => 'def'

    follow_redirect!
    assert_equal '/C', last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    assert_nil @wiki.page("B")
    page_2 = @wiki.page('C')
    assert_equal "INITIAL\n\nSPAM2\n", page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "renames page catches invalid page" do
    # No such page
    post "/rename/no-such-file-here", :rename => "/C", :message => 'def'
    assert !last_response.ok?
    assert_equal last_response.status, 500
  end

  test "rename page catches empty target" do
    # Empty rename target
    post "/rename/B", :rename => "", :message => 'def'
    assert !last_response.ok?
    assert_equal last_response.status, 500
  end

  test "rename page catches non-existent target" do
    # Non-existent rename target
    post "/rename/B", :message => 'def'
    assert !last_response.ok?
    assert_equal last_response.status, 500
  end


  test "renames page in subdirectory" do
    page_1 = @wiki.paged("H", "G")
    assert_not_equal page_1, nil
    post "/rename/G/H", :rename => "/I/C", :message => 'def'

    follow_redirect!
    assert_equal '/I/C', last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    assert_nil @wiki.paged("H", "G")
    page_2 = @wiki.paged('C', 'I')
    assert_equal "INITIAL\n\nSPAM2\n", page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "renames page relative in subdirectory" do
    page_1 = @wiki.paged("H", "G")
    assert_not_equal page_1, nil
    post "/rename/G/H", :rename => "K/C", :message => 'def'

    follow_redirect!
    assert_equal '/G/K/C', last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    assert_nil @wiki.paged("H", "G")
    page_2 = @wiki.paged('C', 'G/K')
    assert_equal "INITIAL\n\nSPAM2\n", page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end


  test "creates page" do
    post "/create", :content => 'abc', :page => "D",
      :format => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    page = @wiki.page('D')
    assert_equal 'abc', page.raw_data
    assert_equal 'def', page.version.message
  end

  test "creates pages with escaped characters in title" do
    post "/create", :content => 'abc', :page => 'Title with spaces',
      :format => 'markdown', :message => 'foo'
    assert_equal 'http://example.org/title-with-spaces', last_response.headers['Location']
    get "/Title-with-spaces"
    assert_match /abc/, last_response.body
  end

  test "redirects to create on non-existant page" do
    name = "E"
    get "/#{name}"
    follow_redirect!
    assert_equal "/create/#{name}", last_request.fullpath
    assert last_response.ok?
  end

  test "accessing non-existant directory redirects to create index page" do
    get "/foo/"

    follow_redirect!
    assert_equal "/create/foo/Home", last_request.fullpath
    assert last_response.ok?
  end

  test "accessing redirectory redirects to index page" do
    post "/create", :content => 'abc', :page => 'Home', :path => '/foo/',
      :format => 'markdown', :message => 'foo'

    assert_equal "http://example.org/foo/home", last_response.headers['Location']

    follow_redirect!
    assert last_response.ok?
  end

  test "edit redirects to create on non-existant page" do
    name = "E"
    get "/edit/#{name}"
    follow_redirect!
    assert_equal "/create/#{name}", last_request.fullpath
    assert last_response.ok?
  end

  test "create redirects to page if already exists" do
    name = "A"
    get "/create/#{name}"
    follow_redirect!
    assert_equal "/#{name}", last_request.fullpath
    assert last_response.ok?
  end

  test "create sets the correct path for a relative path subdirectory" do
    dir = "foodir"
    name = "#{dir}/bar"
    get "/create/#{name}"
    assert_match(/\/#{dir}/, last_response.body)
    assert_not_match(/[^\/]#{dir}/, last_response.body)
  end

  test "create sets the correct path for a relative path subdirectory with the page file directory set" do
    Precious::App.set(:wiki_options, {:page_file_dir => "foo"})
    dir = "bardir"
    name = "#{dir}/baz"
    get "/create/foo/#{name}"
    assert_match(/\/#{dir}/, last_response.body)
    assert_not_match(/[^\/]#{dir}/, last_response.body)
    # reset page_file_dir
    Precious::App.set(:wiki_options, {:page_file_dir => nil})
  end

  test "edit returns nil for non-existant page" do
    # post '/edit' fails. post '/edit/' works.
    page = 'not-real-page'
    path = '/'
    post '/edit/', :content => 'edit_msg',
      :page => page, :path => path, :message => ''
    page_e = @wiki.paged(page, path)
    assert_equal nil, page_e
  end

  test "page create and edit with dash & page rev" do
    page = 'c-d-e'
    path = 'a/b/' # path must end with /

    post '/create', :content => 'create_msg', :page => page,
      :path => path, :format => 'markdown', :message => ''
    page_c = @wiki.paged(page, path)
    assert_equal 'create_msg', page_c.raw_data

    # must clear or create_msg will be returned
    @wiki.clear_cache

    # post '/edit' fails. post '/edit/' works.
    post '/edit/', :content => 'edit_msg',
      :page => page, :path => path, :message => ''
    page_e = @wiki.paged(page, path)
    assert_equal 'edit_msg', page_e.raw_data

    @wiki.clear_cache

    # test `get %r{/(.+?)/([0-9a-f]{40})} do` in app.rb
    get '/' + page_c.escaped_url_path + '/' + page_c.version.to_s
    assert last_response.ok?
    assert_match /create_msg/, last_response.body

    get '/' + page_e.escaped_url_path + '/' + page_e.version.to_s
    assert last_response.ok?
    assert_match /edit_msg/, last_response.body
  end

  test "guards against creation of existing page" do
    name = "A"
    post "/create", :content => 'abc', :page => name,
      :format => 'markdown', :message => 'def'

    assert last_response.ok?

    @wiki.clear_cache
    page = @wiki.page(name)
    assert_not_equal 'abc', page.raw_data
  end

  test "delete a page" do
    name = "deleteme"
    post "/create", :content => 'abc', :page => name,
      :format => 'markdown', :message => 'foo'
    page = @wiki.page(name)
    assert_equal 'abc', page.raw_data

    get '/delete/' + name

    @wiki.clear_cache
    page = @wiki.page(name)
    assert_equal nil, page
  end

  test "previews content" do
    post "/preview", :content => 'abc', :format => 'markdown'
    assert last_response.ok?
  end

  test "previews content on the first page of an empty wiki" do
    @path = cloned_testpath("examples/empty.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {})

    post "/preview", :content => 'abc', :format => 'markdown'
    assert last_response.ok?
  end

=begin
  # Grit is broken.
  test "reverts single commit" do
    page1 = @wiki.page('B')

    post "/revert/B/7c45b5f16ff3bae2a0063191ef832701214d4df5"
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page('B')
    assert_not_equal page1.version.sha, page2.version.sha
    assert_equal "INITIAL", page2.raw_data.strip
#    assert_equal "Revert commit #7c45b5f", page2.version.message
  end

  test "reverts multiple commits" do
    page1 = @wiki.page('A')

    post "/revert/A/fc66539528eb96f21b2bbdbf557788fe8a1196ac/b26b791cb7917c4f37dd9cb4d1e0efb24ac4d26f"
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page('A')
    assert_not_equal page1.version.sha, page2.version.sha
    assert_equal "INITIAL", page2.raw_data.strip
  end
=end

  test "cannot revert conflicting commit" do
    page1 = @wiki.page('A')

    post "/revert/A/302a5491a9a5ba12c7652ac831a44961afa312d2"
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page('A')
    assert_equal page1.version.sha, page2.version.sha
  end
=begin
  # redirects are now handled by class MapGollum in bin/gollum
  # they should be set in config.ru

  test "redirects from 'base_path' or 'base_path/' to 'base_path/Home'" do
    Precious::App.set(:wiki_options, {})
    get "/"
    assert_match "http://example.org/Home", last_response.headers['Location']

    Precious::App.set(:wiki_options, { :base_path => '/wiki' })
    get "/"
    assert_match "http://example.org/wiki/Home", last_response.headers['Location']

    Precious::App.set(:wiki_options, { :base_path => '/wiki/' })
    get "/"
    assert_match "http://example.org/wiki/Home", last_response.headers['Location']

    # Reset base path
    Precious::App.set(:wiki_options, { :base_path => nil })
  end
=end

  test "author details in session are used" do
    page1 = @wiki.page('A')

    gollum_author = { :name => 'ghi', :email => 'jkl' }
    session = { 'gollum.author' => gollum_author }

    post "/edit/A", { :content => 'abc', :page => 'A', :format => page1.format, :message => 'def' }, { 'rack.session' => session }
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page(page1.name)

    author = page2.version.author
    assert_equal 'ghi', author.name
    assert_equal 'jkl', author.email
  end

  test "do not add custom.js by default" do
    page = 'nocustom'
    text = 'nope none'

    @wiki.write_page(page, :markdown, text,
                     { :name => 'user1', :email => 'user1' });

    get page
    assert_no_match /custom.js/, last_response.body
  end

  test "add custom.js if setting" do
    Precious::App.set(:wiki_options, { :js => true })
    page = 'yaycustom'
    text = 'customized!'

    @wiki.write_page(page, :markdown, text,
                     { :name => 'user1', :email => 'user1' });

    get page
    assert_match /custom.js/, last_response.body
    Precious::App.set(:wiki_options, { :js => nil })
  end

  def app
    Precious::App
  end
end

context "Frontend with lotr" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {})
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  # Here's the dir structure of lotr.git
  #
  # .
  # ├── Bilbo-Baggins.md
  # ├── Data.csv
  # |-- Data-Two.csv -> Data.csv
  # ├── Gondor
  # │   ├── Boromir.md
  # │   ├── _Footer.md
  # │   ├── _Header.md
  # │   └── _Sidebar.md
  # |-- Hobbit.md -> Bilbo-Baggins.md
  # ├── Home.textile
  # ├── Mordor
  # │   ├── Eye-Of-Sauron.md
  # │   ├── _Footer.md
  # │   ├── _Header.md
  # │   ├── _Sidebar.md
  # │   ├── eye.jpg
  # │   └── todo.txt
  # ├── My-Precious.md
  # ├── Samwise\ Gamgee.mediawiki
  # ├── _Footer.md
  # ├── _Header.md
  # └── _Sidebar.md
  #

  test "/pages" do
    get "/pages"
    assert last_response.ok?

    body = last_response.body

    assert body.include?("Bilbo Baggins"), "/pages should include the page 'Bilbo Baggins'"
    assert body.include?("Gondor"), "/pages should include the folder 'Gondor'"
    assert !body.include?("Boromir"), "/pages should NOT include the page 'Boromir'"
    assert body.include?("Mordor"), "/pages should include the folder 'Mordor'"
    assert !body.include?("Eye Of Sauron"), "/pages should NOT include the page 'Eye Of Sauron'"
  end

  test "/pages/Mordor/" do
    get "/pages/Mordor/"
    assert last_response.ok?, "/pages/Mordor/ did not respond ok"

    body = last_response.body

    assert !body.include?("Bilbo Baggins"), "/pages/Mordor/ should NOT include the page 'Bilbo Baggins'"
    assert body.include?("Eye Of Sauron"), "/pages/Mordor/ should include the page 'Eye Of Sauron'"
  end

  test "symbolic link pages" do
    get "/Hobbit"
    assert_match /Bilbo Baggins/, last_response.body
  end

  # base path requires 'map' in a config.ru to work correctly.
  test "create pages within sub-directories using base path" do
    Precious::App.set(:wiki_options, { :base_path => 'wiki' })
    page = 'path'
    post "/create", :content => '123', :page => page,
      :path => 'Mordor', :format => 'markdown', :message => 'oooh, scary'
    # should be wiki/Mordor/path
    assert_equal 'http://example.org/Mordor/' + page, last_response.headers['Location']
    get '/Mordor/' + page
    assert_match /123/, last_response.body

    # Reset base path
    Precious::App.set(:wiki_options, { :base_path => nil })
  end

  test "create pages within sub-directories using page file dir" do
    post "/create", :content => 'one two', :page => 'base',
      :path => 'wiki/Mordor', :format => 'markdown', :message => 'oooh, scary'
    assert_equal 'http://example.org/wiki/Mordor/base', last_response.headers['Location']
    get "/wiki/Mordor/base"

    assert_match /one two/, last_response.body
  end


  test "create pages within sub-directories" do
    post "/create", :content => 'big smelly creatures', :page => 'Orc',
      :path => 'Mordor', :format => 'markdown', :message => 'oooh, scary'
    assert_equal 'http://example.org/Mordor/orc', last_response.headers['Location']
    get "/Mordor/Orc"
    assert_match /big smelly creatures/, last_response.body

    post "/create", :content => 'really big smelly creatures', :page => 'Uruk Hai',
      :path => 'Mordor', :format => 'markdown', :message => 'oooh, very scary'
    assert_equal 'http://example.org/Mordor/uruk-hai', last_response.headers['Location']
    get "/Mordor/Uruk-Hai"
    assert_match /really big smelly creatures/, last_response.body
  end

  test "edit pages within sub-directories" do
    post "/create", :content => 'big smelly creatures', :page => 'Orc',
      :path => 'Mordor', :format => 'markdown', :message => 'oooh, scary'

    assert_equal 'http://example.org/Mordor/orc', last_response.headers['Location']

    post "/edit/Mordor/Orc", :content => 'not so big smelly creatures',
      :page => 'Orc', :path => 'Mordor', :message => 'minor edit'
    assert_equal 'http://example.org/Mordor/orc', last_response.headers['Location']

    get "/Mordor/Orc"
    assert_match /not so big smelly creatures/, last_response.body
  end

  def app
    Precious::App
  end
end
