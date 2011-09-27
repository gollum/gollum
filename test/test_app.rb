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

  test "edits page" do
    page_1 = @wiki.page('A')
    post "/edit/A", :content => 'abc',
      :format => page_1.format, :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    assert_equal 'abc', page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "edits page footer and sidebar" do
    commits = @wiki.repo.commits('master').size
    page_1  = @wiki.page('A')
    foot_1  = page_1.footer
    side_1  = page_1.sidebar

    post "/edit/A",
      :footer => 'footer', :page => "A", :sidebar => 'sidebar', :message => 'def'
    follow_redirect!
    assert_equal "/A", last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    foot_2 = page_2.footer
    side_2 = page_2.sidebar
    assert_equal page_1.raw_data, page_2.raw_data

    assert_equal 'footer', foot_2.raw_data
    assert_equal 'def',    foot_2.version.message
    assert_not_equal foot_1.version.sha, foot_2.version.sha

    assert_equal 'sidebar', side_2.raw_data
    assert_equal 'def',     side_2.version.message
    assert_not_equal side_1.version.sha, side_2.version.sha
    assert_equal commits+1, @wiki.repo.commits('master').size
  end

  test "renames page" do
    page_1 = @wiki.page('B')
    post "/edit/B", :content => 'abc',
      :rename => "C",
      :format => page_1.format, :message => 'def'
    follow_redirect!
    assert_equal "/C", last_request.fullpath
    assert last_response.ok?

    @wiki.clear_cache
    assert_nil @wiki.page("B")
    page_2 = @wiki.page('C')
    assert_equal 'abc', page_2.raw_data
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

  test "guards against creation of existing page" do
    name = "A"
    post "/create", :content => 'abc', :page => name,
      :format => 'markdown', :message => 'def'
    assert last_response.ok?

    @wiki.clear_cache
    page = @wiki.page(name)
    assert_not_equal 'abc', page.raw_data
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


  test "reverts single commit" do
    page1 = @wiki.page('B')

    post "/revert/B/7c45b5f16ff3bae2a0063191ef832701214d4df5"
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page('B')
    assert_not_equal page1.version.sha, page2.version.sha
    assert_equal "INITIAL", page2.raw_data.strip
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

  test "cannot revert conflicting commit" do
    page1 = @wiki.page('A')

    post "/revert/A/302a5491a9a5ba12c7652ac831a44961afa312d2"
    assert last_response.ok?

    @wiki.clear_cache
    page2 = @wiki.page('A')
    assert_equal page1.version.sha, page2.version.sha
  end

  def app
    Precious::App
  end
end
