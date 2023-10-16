require_relative "../capybara_helper"

context "viewing a wiki page" do
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

  test "'copy to clipboard' functionality on code blocks" do
    create_page title: "Page with code block", content: <<~TEXT
      This page includes a code block. In this test, we will use the provided
      'copy to clipboard' button to ensure that it works properly.

      ```
      a juicy fish,
      ```

      Here's a second code block to test keyboard navigability:

      ```
      so nice and fresh
      ```
    TEXT

    # Before the test, we ensure the browser has permission to write to the
    # clipboard for the instance of Gollum being served at the current URL.
    #
    page.driver.browser.add_permission "clipboard-write", "granted"

    code_block_1, code_block_2 =
      within "#wiki-content" do
        find_all("pre", wait: 10).to_a
      end

    # Get the code block in focus so the "copy to clipboard" button becomes
    # visible.
    code_block_1.hover

    copy_to_clipboard_button = find_button "copy to clipboard"
    copy_to_clipboard_button.click

    # Check that the contents were copied to the clipboard by pasting them
    # somewhere.
    search_field = find_field("Search site")
    search_field.click

    assert search_field.value, ""
    send_keys [:control, "v"] # paste
    assert search_field.value, "a juicy fish"

    # Ensure that the 'copy to clipboard' button is also keyboard navigable
    # and keyboard usable.
    code_block_2.click

    send_keys :tab
    send_keys :space

    search_field.click
    assert search_field.value, "a juicy fish,"

    send_keys :space
    send_keys [:control, "v"]

    assert search_field.value, "a juicy fish, so nice and fresh"
  end
end
