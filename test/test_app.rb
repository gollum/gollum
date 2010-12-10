# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Frontend" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "edits page" do
    page_1 = @wiki.page('Bilbo Baggins')
    post "/edit/#{Gollum::Page.cname page_1.name}", :content => 'abc', 
      :format => page_1.format, :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.clear_cache
    page_2 = @wiki.page(page_1.name)
    assert_equal 'abc', page_2.raw_data
    assert_equal 'def', page_2.version.message
    assert_not_equal page_1.version.sha, page_2.version.sha
  end

  test "creates page" do
    post "/create", :content => 'abc', :page => "Newbie",
      :format => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    page = @wiki.page('Newbie')
    assert_equal 'abc', page.raw_data
    assert_equal 'def', page.version.message
  end

  test "guards against creation of existing page" do
    name = "Bilbo Baggins"
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

  def app
    Precious::App
  end
end