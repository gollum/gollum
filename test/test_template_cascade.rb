# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/page', __FILE__

context "Precious::Views::TemplateCascade" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath('examples/lotr.git')
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {template_dir: testpath('examples/template_cascade')})
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  def app
    Precious::App
  end

  test "overriden template is used" do
    get '/Home'
    assert_equal '/Home', last_request.fullpath
    assert last_response.ok?
    assert last_response.body.include?('PAGE_OVERRIDE')
    assert last_response.body.include?('NAVBAR_OVERRIDE')
  end

end
