# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

context "Precious::Views::Editing" do
  include Rack::Test::Methods
  setup do
    examples = testpath "examples"
    @path    = File.join(examples, "test.git")
    Precious::App.set(:gollum_path, @path)
    FileUtils.cp_r File.join(examples, "revert.git"), @path, :remove_destination => true
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
  end

  test "creating page is blocked" do
    Precious::App.set(:wiki_options, { allow_editing: false})
    post "/gollum/create", :content => 'abc', :page => "D",
         :format             => 'markdown', :message => 'def'
    assert !last_response.ok?

    page = @wiki.page('D')
    assert page.nil?
  end


  test "frontend links for editing are not blocked" do
    Precious::App.set(:wiki_options, { allow_editing: true, allow_uploads: true })
    get '/A'

    assert_match /Delete this Page/, last_response.body, "'Delete this Page' link is blocked in page template"
    assert_match /New/,              last_response.body, "'New' button is blocked in page template"
    assert_match /Upload\b/,         last_response.body, "'Upload' link is blocked in page template"
    assert_match /Rename/,           last_response.body, "'Rename' link is blocked in page template"
    assert_match /Edit/,             last_response.body, "'Edit' link is blocked in page template"

    get '/gollum/pages'

    assert_match /New/, last_response.body, "'New' link is blocked in pages template"

    get '/gollum/history/A'

    assert_match /Edit/, last_response.body, "'Edit' link is blocked in history template"

    get '/gollum/compare/A/fc66539528eb96f21b2bbdbf557788fe8a1196ac..b26b791cb7917c4f37dd9cb4d1e0efb24ac4d26f'

    assert_match /Edit Page/,             last_response.body, "'Edit Page' link is blocked in compare template"
    assert_match /Revert Changes/,        last_response.body, "'Revert Changes' link is blocked in compare template"
  end

  test "frontend links for editing blocked" do
    Precious::App.set(:wiki_options, { allow_editing: false })
    get '/A'

    assert_no_match /Delete this Page/, last_response.body, "'Delete this Page' link not blocked in page template"
    assert_no_match /New/,              last_response.body, "'New' button not blocked in page template"
    assert_no_match /Upload\b/,         last_response.body, "'Upload' link not blocked in page template"
    assert_no_match /Rename/,           last_response.body, "'Rename' link not blocked in page template"
    assert_no_match /Edit/,             last_response.body, "'Edit' link not blocked in page template"

    get '/gollum/pages'

    assert_no_match /New/, last_response.body, "'New' link not blocked in pages template"

    get '/gollum/history/A'

    assert_no_match /Edit/, last_response.body, "'Edit' link not blocked in history template"

    get '/gollum/compare/A/fc66539528eb96f21b2bbdbf557788fe8a1196ac..b26b791cb7917c4f37dd9cb4d1e0efb24ac4d26f'

    assert_no_match /Edit Page/,             last_response.body, "'Edit Page' link not blocked in compare template"
    assert_no_match /Revert Changes/,        last_response.body, "'Revert Changes' link not blocked in compare template"
  end

  def app
    Precious::App
  end
end