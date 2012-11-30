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

  test "create and read non-latin page with anchor" do
    @wiki.write_page("test", :markdown, "# 한글")

    page = @wiki.page("test")
    assert_equal Gollum::Page, page.class
    assert_equal "# 한글", utf8(page.raw_data)

    # markup.rb
    doc     = Nokogiri::HTML page.formatted_data
    h1s     = doc / :h1
    h1      = h1s.first
    anchors = h1 / :a
    assert_equal 1, h1s.size
    assert_equal 1, anchors.size
    assert_equal '#한글',  anchors[0]['href']
    assert_equal  '한글',  anchors[0]['id']
    assert_equal 'anchor', anchors[0]['class']
    assert_equal '',       anchors[0].text
  end

  def test_h1 text, page
      @wiki.write_page(page, :markdown, "# " + text)

      page = @wiki.page(page)
      assert_equal Gollum::Page, page.class
      assert_equal '# ' + text, utf8(page.raw_data)

      # markup.rb
      doc     = Nokogiri::HTML page.formatted_data
      h1s     = doc / :h1
      h1      = h1s.first
      anchors = h1 / :a
      assert_equal 1, h1s.size
      assert_equal 1, anchors.size
      assert_equal '#' + text, anchors[0]['href']
      assert_equal text,       anchors[0]['id']
      assert_equal 'anchor',   anchors[0]['class']
      assert_equal '',         anchors[0].text
  end

  test "create and read non-latin page with anchor" do
    # Nokogiri's anchors[0]['href'] returns unencoded result
    # so the test doesn't fail even though the actual value
    # is encoded.

    # href="#%ED%95%9C%EA%B8%80"
    test_h1 '한글', '1'
    # href="#Synht%C3%A8se"
    test_h1 'Synhtèse', '2'
  end

  test "create and read non-latin page with anchor 2" do
    @wiki.write_page("test", :markdown, "# \"La\" faune d'Édiacara")

    page = @wiki.page("test")
    assert_equal Gollum::Page, page.class
    assert_equal "# \"La\" faune d'Édiacara", utf8(page.raw_data)

    # markup.rb test: ', ", É
    doc     = Nokogiri::HTML page.formatted_data
    h1s     = doc / :h1
    h1      = h1s.first
    anchors = h1 / :a
    assert_equal 1, h1s.size
    assert_equal 1, anchors.size
    assert_equal %q(#%22La%22-faune-d'Édiacara), anchors[0]['href']
    assert_equal %q(%22La%22-faune-d'Édiacara),  anchors[0]['id']
    assert_equal 'anchor',                 anchors[0]['class']
    assert_equal '',                       anchors[0].text
  end

  test "unicode with existing format rules" do
    @wiki.write_page("test", :markdown, "# 한글")
    assert_equal @wiki.page("test").path, @wiki.page("test").path
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
    post "/create", :content => '한글 text', :page => "k",
      :format => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    page = @wiki.page('k')
    assert_equal '한글 text', utf8(page.raw_data)
    assert_equal 'def', page.version.message
  end

  test "heavy use 1" do
    post "/create", :content => '한글 text', :page => "PG",
      :format => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.update_page(@wiki.page('PG'), nil, nil, '다른 text', {})
    page = @wiki.page('PG')
    assert_equal '다른 text', utf8(page.raw_data)

    post '/edit/PG', :page => 'PG', :content => '바뀐 text', :message => 'ghi'
    follow_redirect!
    assert last_response.ok?

    @wiki = Gollum::Wiki.new(@path)
    page = @wiki.page('PG')
    assert_equal '바뀐 text', utf8(page.raw_data)
    assert_equal 'ghi', page.version.message
  end

  test "heavy use 2" do
    post "/create", :content => '한글 text', :page => "k",
      :format => 'markdown', :message => 'def'
    follow_redirect!
    assert last_response.ok?

    @wiki.update_page(@wiki.page('k'), nil, nil, '다른 text', {})
    @wiki = Gollum::Wiki.new(@path)
    page = @wiki.page('k')
    assert_equal '다른 text', utf8(page.raw_data)

    post '/edit/' + CGI.escape('한글'), :page => 'k', :content => '바뀐 text',
      :format => 'markdown', :message => 'ghi'
    follow_redirect!
    assert last_response.ok?

    @wiki = Gollum::Wiki.new(@path)
    page = @wiki.page('k')
    assert_equal '바뀐 text', utf8(page.raw_data)
    assert_equal 'ghi', page.version.message
  end

  test 'transliteration' do
    # TODO: Remove to_url once write_page changes are merged.
    @wiki.write_page('ééééé'.to_url, :markdown, '한글 text', { :name => '', :email => '' } )
    page = @wiki.page('eeeee')
    assert_equal '한글 text', utf8(page.raw_data)
  end

  def app
    Precious::App
  end
end

