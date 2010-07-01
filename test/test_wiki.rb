require File.join(File.dirname(__FILE__), *%w[helper])

context "Wiki" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "repo path" do
    assert_equal testpath("examples/lotr.git"), @wiki.path
  end

  test "git repo" do
    assert_equal Grit::Repo, @wiki.repo.class
    assert @wiki.exist?
  end
end

context "Wiki page writing" do
  setup do
    @path = testpath("examples/test.git")
    FileUtils.rm_rf(@path)
    Grit::Repo.init_bare(@path)
    @wiki = Gollum::Wiki.new(@path)
  end

  test "write_page" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)
    assert_equal 1, @wiki.repo.commits.size
    assert_equal "Gollum page", @wiki.repo.commits.first.message
    assert_equal "Tom Preston-Werner", @wiki.repo.commits.first.author.name
    assert_equal "tom@github.com", @wiki.repo.commits.first.author.email
    assert @wiki.page("Gollum")

    @wiki.write_page("Bilbo", :markdown, "# Bilbo", commit)
    assert_equal 2, @wiki.repo.commits.size
    assert @wiki.page("Bilbo")
    assert @wiki.page("Gollum")
  end

  test "update_page" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)

    page = @wiki.page("Gollum")
    @wiki.update_page(page, "# Gollum2", commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal "# Gollum2", @wiki.page("Gollum").raw_data
    assert_equal "Gollum page", @wiki.repo.commits.first.message
    assert_equal "Tom Preston-Werner", @wiki.repo.commits.first.author.name
    assert_equal "tom@github.com", @wiki.repo.commits.first.author.email
  end

  test "delete root page" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)

    page = @wiki.page("Gollum")
    @wiki.delete_page(page, commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_nil @wiki.page("Gollum")
  end

  test "delete nested page" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }

    index = @wiki.repo.index
    index.add("greek/Bilbo-Baggins.md", "hi")
    index.add("Gollum.md", "hi")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo-Baggins")
    assert page
    @wiki.delete_page(page, commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_nil @wiki.page("Bilbo-Baggins")

    assert @wiki.page("Gollum")
  end

  test "list pages" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }

    index = @wiki.repo.index
    index.add("greek/Bilbo-Baggins.md", "hi")
    index.add("Gollum.md", "hi")
    index.commit("Add alpha.jpg")

    pages = @wiki.pages
    assert_equal "Gollum.md",              pages[0].path
    assert_equal "Gollum.md",              pages[0].name
    assert_equal "greek/Bilbo-Baggins.md", pages[1].path
    assert_equal "Bilbo-Baggins.md",       pages[1].name
  end

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
  end
end