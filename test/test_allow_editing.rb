# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

context "Precious::Views::Editing" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath('examples/revert.git')
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {allow_editing: true, allow_uploads: true})
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    Precious::App.set(:wiki_options, {allow_editing: true, allow_uploads: true})
    FileUtils.rm_rf(@path)
  end

  test 'creating pages is not blocked' do
    post '/gollum/create',
      content: 'abc',
      format: 'markdown',
      message: 'def',
      page: 'D'

    assert_equal last_response.status, 302

    refute_nil @wiki.page('D')
  end

  test 'creating pages is blocked' do
    Precious::App.set(:wiki_options, {allow_editing: false, allow_uploads: false})

    post '/gollum/create',
      content: 'abc',
      format: 'markdown',
      message: 'def',
      page: 'D'

    assert last_response.body.include? 'Forbidden. This wiki is set to no-edit mode.'

    refute last_response.ok?

    assert_nil @wiki.page('D')
  end

  test ".redirects.gollum file should not be accessible" do
    get '/.redirects.gollum'
    assert_match /Accessing this resource is not allowed/, last_response.body
  end

  test ".redirects.gollum file should not be editable" do
    get '/gollum/edit/.redirects.gollum'
    assert_match /Changing this resource is not allowed/, last_response.body
  end

  test "frontend links for editing are not blocked" do
    get '/A'

    assert last_response.body.include? "Delete this Page"
    assert last_response.body.include? "New"
    assert last_response.body.include? "<span>Upload</span>"
    assert last_response.body.include? "Rename"
    assert last_response.body.include? "Edit"

    get '/gollum/overview'

    assert last_response.body.include? "New"

    get '/gollum/history/A'

    refute last_response.body.include? "Edit"

    get '/gollum/compare/A/fc665395..b26b791c'

    refute last_response.body.include? "Edit Page"

    assert last_response.body.include? "Revert Changes"
  end

  test "frontend links for editing blocked" do
    Precious::App.set(:wiki_options, {allow_editing: false, allow_uploads: false})

    get '/A'

    refute last_response.body.include? "Delete this Page"
    refute last_response.body.include? "<span>Upload</span>"
    refute last_response.body.include? "Rename"
    refute last_response.body.include? "Edit"
    refute last_response.body.include? "New"

    get '/gollum/overview'

    refute last_response.body.include? "New"

    get '/gollum/history/A'

    refute last_response.body.include? "Edit"

    get '/gollum/compare/A/fc665395..b26b791c'

    refute last_response.body.include? "Edit Page"
    refute last_response.body.include? "Revert Changes"
  end

  def app
    Precious::App
  end
end
