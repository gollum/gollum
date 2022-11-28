require_relative "../capybara_helper"

context "pages" do
  include Capybara::DSL

  setup do
    @path = cloned_testpath "examples/lotr.git"
    @wiki = Gollum::Wiki.new @path


    Precious::App.set :gollum_path, @path
    Precious::App.set :wiki_options, {}

    Capybara.app = Precious::App
  end

  test 'last modified link is correctly encoded' do
    visit '/Samwise Gamgee'
    find(:id, 'page-info-toggle').click
    wait_for_ajax
    assert_includes page.text, "Last edited by Arran Cudbard-Bell"    
  end

  teardown do
    @path = nil
    @wiki = nil

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

end