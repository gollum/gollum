# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class TestTemplateCascade < Minitest::Unit::TestCase
  include Rack::Test::Methods

  def setup
    @path = cloned_testpath('examples/lotr.git')
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {template_dir: testpath('examples/template_cascade')})
    @wiki = Gollum::Wiki.new(@path)
  end

  def teardown
    FileUtils.rm_rf(@path)
  end

  def app
    Precious::App
  end

  def test_overridden_page_template_is_used
    get '/Home'

    assert last_response.body.include?('PAGE_OVERRIDE')
  end

  def test_overridden_navbar_partial_is_used
    get '/Home'

    assert last_response.body.include?('NAVBAR_OVERRIDE')
  end

  def test_overridden_templates_are_ignore_without_template_dir_set
    Precious::App.set(:wiki_options, {template_dir: nil})

    get '/Home'
    assert_equal '/Home', last_request.fullpath
    assert last_response.ok?
    assert_no_match /PAGE_OVERRIDE/, last_response.body
    assert_no_match /NAVBAR_OVERRIDE/, last_response.body
  end
end
