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
    using_wait_time 10 do
      fill_in('Search', with: "something-to-return-no-results")
    end
    send_keys :return
    
    using_wait_time 10 do
      assert_includes page.text,
        'Search results for something-to-return-no-results'
      assert_includes page.text,
        'There are no results for your search.'
      click_on 'Back to Top'
    end

    visit '/gollum/search'

    using_wait_time 10 do
      fill_in('Search site', with: "Bilbo")
    end
    send_keys :return
    
    using_wait_time 10 do
      assert_includes page.text, 'Search results for Bilbo'
      click_on 'Show all hits on this page'
      click_on 'Bilbo-Baggins.md'
    end

    using_wait_time 10 do
      assert page.current_path, '/Bilbo-Baggins.md'
    end
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
