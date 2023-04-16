require_relative "../capybara_helper"

context "pages using Asciidoctor" do
  include Capybara::DSL

  setup do
    @path = cloned_testpath "examples/lotr.git"
    @wiki = Gollum::Wiki.new @path

    Precious::App.set :gollum_path, @path
    Precious::App.set :wiki_options, {}

    Capybara.app = Precious::App
  end

  test 'Asciidoctor links are rendered correctly' do
    visit "/"

    within "#head" do
      click_on "New"
    end

    assert page.text.include? "Create New Page"

    fill_in "Page Name", with: "My Asciidoctor article"
    click_on "OK"

    assert page.text.include? "Create New Page"
    assert asciidoc_renderer_available?

    # FIXME:
    # We should be able to use `#select` to select the AsciiDoc markup option.
    # But it doesn't seem to work:
    #
    #     select "AsciiDoc", from: "Markup"
    #
    # This makes me think there's an accessibility issue with this <select>
    # dropdown, but I'm not sure what it is.
    #
    markup_format_selector = find "select#wiki_format"
    markup_format_selector.select "AsciiDoc"

    add_page_content <<~TEXT
      This page content will test that our AsciiDoc renderer renders documents
      well.

      Here is a typical HTTP hyperlink:
      link:https://github.com/gollum/gollum[gollum/gollum on GitHub]

      Here is a Matrix link:
      link:matrix:u/foo:example.org[matrix link example]

      Here is a magnet link:
      link:magnet:?xt=urn:sha1:ABCDEFGHIJK[magnet link example]
    TEXT

    click_on "Save"

    assert page.body.include?(<<~TEXT.strip)
      Here is a typical HTTP hyperlink:
      <a href="https://github.com/gollum/gollum">gollum/gollum on GitHub</a>
    TEXT

    # FIXME
    skip 'The assertions after this line will fail until #1959 is resolved:' \
      'https://github.com/gollum/gollum/issues/1959'

    assert page.body.include?(<<~TEXT.strip)
      Here is a Matrix link:
      <a href="matrix:u/foot:example.org">matrix link example</a>
    TEXT

    assert page.body.include?(<<~TEXT.strip)
      Here is a magnet link:
      <a href="magnet:?xt=urn:sha1:ABCDEFGHIJK">magnet link example</a>
    TEXT
  end

  def add_page_content text
    # Ensure the main editor is in focus before adding text.
    find(".ace_content").click

    page.send_keys text
  end

  def asciidoc_renderer_available?
    within "select#wiki_format" do
      asciidoc_option = find "option[data-ext='adoc']"
      !asciidoc_option[:class].match? /disabled/
    end
  end
end
