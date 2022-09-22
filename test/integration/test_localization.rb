require_relative '../capybara_helper'

context 'Localized frontend' do
  include Capybara::DSL

  setup do
    @path = cloned_testpath "examples/lotr.git"
    @wiki = Gollum::Wiki.new(@path)

    Precious::App.set :gollum_path, @path
    Precious::App.set :wiki_options, {mathjax: true}

    Capybara.app = Precious::App
  end

  test 'can visit search results page' do
    visit '/gollum/search'

    fill_in('Search', with: 'something-to-return-no-results')
      .native
      .send_keys(:return)

    assert_includes page.text,
      'Search results for something-to-return-no-results'
    assert_includes page.text,
      'There are no results for your search something-to-return-no-results.'

    click_on 'Back to Top'

    visit '/gollum/search'

    fill_in('Search', with: 'Bilbo').native.send_keys(:return)

    assert_includes page.text, 'Search results for Bilbo'

    click_on 'Show all hits on this page'
    click_on 'Bilbo-Baggins.md'

    assert page.current_path, '/Bilbo-Baggins.md'
  end

  test 'can visit overview page' do
    visit "/gollum/overview"

    assert_includes page.text, 'Overview of master'
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
