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
    assert_equal 'Bilbo-Baggins.md', page.path
    assert_equal :markdown, page.format
    assert_equal @wiki.repo.commits.first.id, page.version.id
  end

  test "get nested page" do
    page = @wiki.page('Eye Of Sauron')
    assert_equal 'Mordor/Eye-Of-Sauron.md', page.path
  end

  test "page versions" do
    page = @wiki.page('Bilbo Baggins')
    assert_equal ['5bc1aaec6149e854078f1d0f8b71933bbc6c2e43'],
      page.versions.map { |v| v.id }
  end

  test "specific page version" do
    page = @wiki.page('Bilbo Baggins', 'fbabba862dfa7ac35b39042dd4ad780c9f67b8cb')
    assert_equal 'fbabba862dfa7ac35b39042dd4ad780c9f67b8cb', page.version.id
  end

  test "no page match" do
    assert_nil @wiki.page('I do not exist')
  end

  test "no ext match" do
    assert_nil @wiki.page('Data')
  end
end