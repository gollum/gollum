require_relative "../capybara_helper"

context "search" do
  include Capybara::DSL

  setup do
    @path = cloned_testpath "examples/lotr.git"
    @wiki = Gollum::Wiki.new @path

    Precious::App.set :gollum_path, @path
    Precious::App.set :wiki_options, {}

    Capybara.app = Precious::App
  end

  teardown do
    @path = nil
    @wiki = nil

    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  test "search interface works when there are many results" do
    visit "/"

    search_term = "#find-me"
    (find_field 'Search site').fill_in with: search_term
    send_keys :enter

    find 'h1', text: "Search results for #find-me"

    page_one_search_results = find_all ".search-result"
    assert_equal page_one_search_results.count, 10

    click_link "Next"
    assert on_page_two?

    assert_includes page.text, "Search results for #find-me"

    # Regression test.
    #
    # We saw an issue where search terms were not encoded as URL parameters
    # correctly in pagination links when special characters like "#" were
    # present in the search term.
    page_two_search_results = find_all ".search-result"
    assert_equal page_two_search_results.count, 1
  end

  test "ignore file types" do
    visit "/"

    search_term = "Bilbo"
    (find_field 'Search site').fill_in with: search_term
    send_keys :enter

    find 'h1', text: "Search results for Bilbo"

    # Now on search page, apply ignore
    fill_in 'ignore-file-types', with: 'csv'
    click_button 'Apply'

    search_results = find_all ".search-result"
    # Should find Bilbo-Baggins.md but not Data.csv
    assert search_results.count > 0
    assert_includes page.text, "Bilbo-Baggins"
    refute_includes page.text, "Data.csv"
  end

  test "ignore strings" do
    visit "/"

    search_term = "Bilbo"
    (find_field 'Search site').fill_in with: search_term
    send_keys :enter

    find 'h1', text: "Search results for Bilbo"

    # Now on search page, apply ignore
    fill_in 'ignore-strings', with: 'Tolkien'
    click_button 'Apply'

    search_results = find_all ".search-result"
    # Should find Data.csv but not Bilbo-Baggins.md
    assert search_results.count > 0
    assert_includes page.text, "Data.csv"
    refute_includes page.text, "Bilbo-Baggins"
  end

  def on_page_two?
    page.current_url.include? "page_num=2"
  end
end
