require 'helper'

context "Page" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "formatted page" do
    page = @wiki.formatted_page('Bilbo Baggins')
    assert_equal Gollum::Page, page.class
    assert page.data =~ /^# Bilbo Baggins\n\nBilbo Baggins/
  end

  test "no page match" do
    assert_nil @wiki.formatted_page('I do not exist')
  end

  test "no ext match" do
    assert_nil @wiki.formatted_page('Data')
  end
end