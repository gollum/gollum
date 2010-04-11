require File.join(File.dirname(__FILE__), *%w[helper])

context "Page" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "new page" do
    page = Gollum::Page.new(@wiki)
    assert_nil page.raw_data
    assert_nil page.formatted_data
  end

  test "get existing page" do
    page = @wiki.page('Bilbo Baggins')
    assert_equal Gollum::Page, page.class
    assert page.raw_data =~ /^# Bilbo Baggins\n\nBilbo Baggins/
    assert page.formatted_data =~ /<h1>Bilbo Baggins<\/h1>\n\n<p>Bilbo Baggins/
    assert_equal :markdown, page.format
    assert_equal 'df26e61e707116f81ebc6b935ec6d1676b7e96c4', page.version.id
  end

  test "no page match" do
    assert_nil @wiki.page('I do not exist')
  end

  test "no ext match" do
    assert_nil @wiki.page('Data')
  end
end