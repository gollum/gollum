require File.join(File.dirname(__FILE__), *%w[helper])

context "Markup" do
  setup do
    @path = testpath("examples/test.git")
    FileUtils.rm_rf(@path)
    Grit::Repo.init_bare(@path)
    @wiki = Gollum::Wiki.new(@path)

    commit = { :message => "Bilbo page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Bilbo Baggins]] b", commit)
  end

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
  end

  test "page link" do
    page = @wiki.page("Bilbo Baggins")
    output = Gollum::Markup.new(page).render
    assert_equal %{<p>a <a href="Bilbo-Baggins">Bilbo Baggins</a> b</p>\n}, output
  end
end
