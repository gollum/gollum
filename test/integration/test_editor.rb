require_relative "../capybara_helper"

context "editor interface" do
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

  test "editor renders help panel" do
    visit "/create/new-article"

    in_editor_toolbar do
      click_on "Help"
    end

    help_widget = find "#gollum-editor-help"

    within help_widget do
      click_on "Miscellaneous"
      click_on "Emoji"

      assert_includes page.text,
        "Gollum uses JoyPixels 4 for its emoji. To include one, wrap the "  \
        "emoji name in colons and use underscores instead of spaces (e.g. " \
        ":heart: or :point_up:)."
    end

  end

  def in_editor_toolbar &block
    return unless block_given?

    within "#gollum-editor-function-bar" do
      yield
    end
  end
end
