# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

context "Precious::Views::TemplateCascade" do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath('examples/lotr.git')
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(
      :wiki_options,
      {template_dir: testpath('examples/template_cascade')}
    )
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_rf(@path)

    Precious::App.set(:wiki_options, {template_dir: nil})

    # The following line has been added to avoid order-dependent test failures.
    # We saw issues where the class variable `@@template_priority_path` was not
    # being reset between test cases.
    Precious::Views::TemplateCascade.class_variable_set(
      :@@template_priority_path,
      nil
    )
  end

  def app
    Precious::App.new
  end

  test "overridden_page_template_is_used" do
    get '/Home'

    assert last_response.body.include?('PAGE_OVERRIDE')
  end

  test "test_overridden_navbar_partial_is_used" do
    get '/Home'

    assert last_response.body.include?('NAVBAR_OVERRIDE')
  end

  test "test_overridden_templates_are_ignore_without_template_dir_set" do
    Precious::App.set(:wiki_options, {template_dir: nil})

    get '/Home'

    assert_equal '/Home', last_request.fullpath

    assert last_response.ok?

    refute_match /PAGE_OVERRIDE/, last_response.body
    refute_match /NAVBAR_OVERRIDE/, last_response.body
  end
end
