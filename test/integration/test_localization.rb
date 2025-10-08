require_relative '../capybara_helper'

context 'Localized frontend' do
  include Capybara::DSL

  setup do
    @path = cloned_testpath "examples/lotr.git"
    @wiki = Gollum::Wiki.new(@path)

    Precious::App.set :gollum_path, @path
    Precious::App.set :wiki_options, {math: :katex}

    Capybara.app = Precious::App
  end

  test 'can visit search results page' do
    visit '/gollum/search'
    (find_field 'Search').fill_in with: "something-to-return-no-results"
    send_keys :return
    
    find 'h1', text: 'Search results for something-to-return-no-results'
    find 'p', text: 'There are no results for your search.'
    click_on 'Back to Top'

    visit '/gollum/search'

    (find_field 'Search site').fill_in with: "Bilbo"
    send_keys :return

    find 'h1', text: 'Search results for Bilbo'
    click_on 'Show all hits on this page'
    (find_link 'Bilbo-Baggins.md').click()

    assert page.current_path, '/Bilbo-Baggins.md'
  end

  test 'can visit overview page' do
    visit "/gollum/overview"

    assert_includes page.text, 'Overview of main'
    assert_includes page.text, 'Home'

    click_on 'Back to Top'
    click_on 'Bilbo-Baggins.md'

    assert page.current_path, '/Bilbo-Baggins.md'
  end

  teardown do
    @path = nil
    @wiki = nil

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
