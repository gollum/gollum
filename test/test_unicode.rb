# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

def utf8(str)
  str.respond_to?(:force_encoding) ? str.force_encoding('utf-8') : str
end

context "Unicode Support" do
  setup do
    @path = cloned_testpath("examples/revert.git")
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "uri encode" do
    c = '한글'
    assert_equal '%ED%95%9C%EA%B8%80', encodeURIComponent(c)
    assert_equal '%ED%95%9C%EA%B8%80', CGI::escape(c)
  end
end

context "Frontend Unicode support" do
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

  test "creates korean page which contains korean content" do
    post "/gollum/create", :content => '한글 text', :page => "k",
         :format             => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    page = @wiki.page('k')
    assert_equal '한글 text', utf8(page.raw_data)
    assert_equal 'def', page.version.message
  end

  test "heavy use 1" do
    post "/gollum/create", :content => '한글 text', :page => "PG",
         :format             => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.update_page(@wiki.page('PG'), nil, nil, '다른 text', {})
    page = @wiki.page('PG')
    assert_equal '다른 text', utf8(page.raw_data)

    post '/gollum/edit/PG', :page => 'PG', :content => '바뀐 text', :message => 'ghi', :etag => page.sha
    assert last_response.ok?

    @wiki = Gollum::Wiki.new(@path)
    page  = @wiki.page('PG')
    assert_equal '바뀐 text', utf8(page.raw_data)
    assert_equal 'ghi', page.version.message
  end

  test "heavy use 2" do
    post "/gollum/create", :content => '한글 text', :page => "k",
         :format             => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.update_page(@wiki.page('k'), nil, nil, '다른 text', {})
    @wiki = Gollum::Wiki.new(@path)
    page  = @wiki.page('k')
    assert_equal '다른 text', utf8(page.raw_data)

    post '/gollum/edit/' + CGI.escape('한글'), :page => 'k', :content => '바뀐 text',
         :format => 'markdown', :message => 'ghi', :etag => page.sha
    assert last_response.ok?

    @wiki = Gollum::Wiki.new(@path)
    page  = @wiki.page('k')
    assert_equal '바뀐 text', utf8(page.raw_data)
    assert_equal 'ghi', page.version.message
  end

  test 'unicode filenames' do
    # we transliterate only when adapter is grit
    return if defined?(Gollum::GIT_ADAPTER) && Gollum::GIT_ADAPTER != 'grit'
    
    @wiki.write_page("ééééé".to_url, :markdown, '한글 text', { :name => '', :email => '' })
    page = @wiki.page("eeeee".to_url)
    assert_equal '한글 text', utf8(page.raw_data)
  end

  def app
    Precious::App
  end
end

