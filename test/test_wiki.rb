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

  test "shows paginated log with no page" do
    Gollum::Wiki.per_page = 3
    commits = @wiki.repo.commits[0..2].map { |x| x.id }
    assert_equal commits, @wiki.log.map { |c| c.id }
  end

  test "shows paginated log with 1st page" do
    Gollum::Wiki.per_page = 3
    commits = @wiki.repo.commits[0..2].map { |x| x.id }
    assert_equal commits, @wiki.log(:page => 1).map { |c| c.id }
  end

  test "shows paginated log with next page" do
    Gollum::Wiki.per_page = 3
    commits = @wiki.repo.commits[3..5].map { |x| x.id }
    assert_equal commits, @wiki.log(:page => 2).map { |c| c.id }
  end

  test "list pages" do
    pages = @wiki.pages
    assert_equal \
      %w(Bilbo-Baggins.md Eye-Of-Sauron.md Home.textile My-<b>Precious.md), 
      pages.map { |p| p.filename }.sort
  end
end

context "Wiki page previewing" do
  setup do
    @path = testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
  end

  test "preview_page" do
    page = @wiki.preview_page("Test", "# Bilbo", :markdown)
    assert_equal "# Bilbo", page.raw_data
    assert_equal "<h1>Bilbo</h1>", page.formatted_data
    assert_equal "Test.md", page.filename
    assert_equal "Test", page.name
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
    @wiki.update_page(page, page.name, :markdown, "# Gollum2", commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal "# Gollum2", @wiki.page("Gollum").raw_data
    assert_equal "Gollum page", @wiki.repo.commits.first.message
    assert_equal "Tom Preston-Werner", @wiki.repo.commits.first.author.name
    assert_equal "tom@github.com", @wiki.repo.commits.first.author.email
  end

  test "update page with format change" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, page.name, :textile, "h1. Gollum", commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal :textile, @wiki.page("Gollum").format
    assert_equal "h1. Gollum", @wiki.page("Gollum").raw_data
  end

  test "update page with name change" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, 'Smeagol', :markdown, "h1. Gollum", commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal "h1. Gollum", @wiki.page("Smeagol").raw_data
  end

  test "update page with name and format change" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, 'Smeagol', :textile, "h1. Gollum", commit)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal :textile, @wiki.page("Smeagol").format
    assert_equal "h1. Gollum", @wiki.page("Smeagol").raw_data
  end

  test "update nested page with format change" do
    commit = { :message => "Gollum page",
               :name => "Tom Preston-Werner",
               :email => "tom@github.com" }

    index = @wiki.repo.index
    index.add("lotr/Gollum.md", "# Gollum")
    index.commit("Add nested page")

    page = @wiki.page("Gollum")
    assert_equal :markdown, @wiki.page("Gollum").format
    @wiki.update_page(page, page.name, :textile, "h1. Gollum", commit)

    page = @wiki.page("Gollum")
    assert_equal "lotr/Gollum.textile", page.path
    assert_equal :textile, page.format
    assert_equal "h1. Gollum", page.raw_data
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

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
  end
end