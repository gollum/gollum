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

    create_page name: "Result 1", content: search_term
    create_page name: "Result 2", content: search_term
    create_page name: "Result 3", content: search_term
    create_page name: "Result 4", content: search_term
    create_page name: "Result 5", content: search_term
    create_page name: "Result 6", content: search_term
    create_page name: "Result 7", content: search_term
    create_page name: "Result 8", content: search_term
    create_page name: "Result 9", content: search_term
    create_page name: "Result 10", content: search_term
    create_page name: "Result 11", content: search_term

    fill_in "Search site", with: search_term
    send_keys :enter

    assert_includes page.text, "Search results for #find-me"

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

  def create_page(name:, content:)
    click_on "New"
    fill_in "Page Name", with: name
    click_on "OK"

    find(".ace_content").click
    send_keys content
    click_on "Save"
  end

  def on_page_two?
    page.current_url.include? "page_num=2"
  end
end
