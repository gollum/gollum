# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

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
      %w(Bilbo-Baggins.md Eye-Of-Sauron.md Home.textile My-Precious.md),
      pages.map { |p| p.filename }.sort
  end

  test "counts pages" do
    assert_equal 4, @wiki.size
  end

  test "normalizes commit hash" do
    commit = {:message => 'abc'}
    name  = @wiki.repo.config['user.name']
    email = @wiki.repo.config['user.email']
    assert_equal({:message => 'abc', :name => name, :email => email},
      @wiki.normalize_commit(commit.dup))

    commit[:name]  = 'bob'
    commit[:email] = ''
    assert_equal({:message => 'abc', :name => 'bob', :email => email},
      @wiki.normalize_commit(commit.dup))

    commit[:email] = 'foo@bar.com'
    assert_equal({:message => 'abc', :name => 'bob', :email => 'foo@bar.com'},
      @wiki.normalize_commit(commit.dup))
  end

  #test "#tree_map_for caches ref and tree" do
  #  assert @wiki.ref_map.empty?
  #  assert @wiki.tree_map.empty?
  #  @wiki.tree_map_for 'master'
  #  assert_equal({"master"=>"60f12f4254f58801b9ee7db7bca5fa8aeefaa56b"}, @wiki.ref_map)
  #
  #  map = @wiki.tree_map['60f12f4254f58801b9ee7db7bca5fa8aeefaa56b']
  #  assert_equal 'Bilbo-Baggins.md',        map[0].path
  #  assert_equal '',                        map[0].dir
  #  assert_equal map[0].path,               map[0].name
  #  assert_equal 'Mordor/Eye-Of-Sauron.md', map[3].path
  #  assert_equal '/Mordor',                 map[3].dir
  #  assert_equal 'Eye-Of-Sauron.md',        map[3].name
  #end
  #
  #test "#tree_map_for only caches tree for commit" do
  #  assert @wiki.tree_map.empty?
  #  @wiki.tree_map_for '60f12f4254f58801b9ee7db7bca5fa8aeefaa56b'
  #  assert @wiki.ref_map.empty?
  #
  #  entry = @wiki.tree_map['60f12f4254f58801b9ee7db7bca5fa8aeefaa56b'][0]
  #  assert_equal 'Bilbo-Baggins.md', entry.path
  #end

  test "text_data" do
    wiki = Gollum::Wiki.new(testpath("examples/yubiwa.git"))
    if String.instance_methods.include?(:encoding)
      utf8 = wiki.page("strider").text_data
      assert_equal Encoding::UTF_8, utf8.encoding
      sjis = wiki.page("sjis").text_data(Encoding::SHIFT_JIS)
      assert_equal Encoding::SHIFT_JIS, sjis.encoding
    else
      page = wiki.page("strider")
      assert_equal page.raw_data, page.text_data
    end
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
    cd = commit_details
    @wiki.write_page("Gollum", :markdown, "# Gollum", cd)
    assert_equal 1, @wiki.repo.commits.size
    assert_equal cd[:message], @wiki.repo.commits.first.message
    assert_equal cd[:name], @wiki.repo.commits.first.author.name
    assert_equal cd[:email], @wiki.repo.commits.first.author.email
    assert @wiki.page("Gollum")

    @wiki.write_page("Bilbo", :markdown, "# Bilbo", commit_details)
    assert_equal 2, @wiki.repo.commits.size
    assert @wiki.page("Bilbo")
    assert @wiki.page("Gollum")
  end

  test "is not allowed to overwrite file" do
    @wiki.write_page("Abc-Def", :markdown, "# Gollum", commit_details)
    assert_raises Gollum::DuplicatePageError do
      @wiki.write_page("ABC DEF", :textile,  "# Gollum", commit_details)
    end
  end

  test "update_page" do
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit_details)

    page = @wiki.page("Gollum")
    cd = commit_details
    @wiki.update_page(page, page.name, :markdown, "# Gollum2", cd)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal "# Gollum2", @wiki.page("Gollum").raw_data
    assert_equal cd[:message], @wiki.repo.commits.first.message
    assert_equal cd[:name], @wiki.repo.commits.first.author.name
    assert_equal cd[:email], @wiki.repo.commits.first.author.email
  end

  test "update page with format change" do
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit_details)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, page.name, :textile, "h1. Gollum", commit_details)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal :textile, @wiki.page("Gollum").format
    assert_equal "h1. Gollum", @wiki.page("Gollum").raw_data
  end

  test "update page with name change" do
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit_details)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, 'Smeagol', :markdown, "h1. Gollum", commit_details)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal "h1. Gollum", @wiki.page("Smeagol").raw_data
  end

  test "update page with name and format change" do
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit_details)

    assert_equal :markdown, @wiki.page("Gollum").format

    page = @wiki.page("Gollum")
    @wiki.update_page(page, 'Smeagol', :textile, "h1. Gollum", commit_details)

    assert_equal 2, @wiki.repo.commits.size
    assert_equal :textile, @wiki.page("Smeagol").format
    assert_equal "h1. Gollum", @wiki.page("Smeagol").raw_data
  end

  test "update nested page with format change" do
    index = @wiki.repo.index
    index.add("lotr/Gollum.md", "# Gollum")
    index.commit("Add nested page")

    page = @wiki.page("Gollum")
    assert_equal :markdown, @wiki.page("Gollum").format
    @wiki.update_page(page, page.name, :textile, "h1. Gollum", commit_details)

    page = @wiki.page("Gollum")
    assert_equal "lotr/Gollum.textile", page.path
    assert_equal :textile, page.format
    assert_equal "h1. Gollum", page.raw_data
  end

  test "delete root page" do
    @wiki.write_page("Gollum", :markdown, "# Gollum", commit_details)

    page = @wiki.page("Gollum")
    @wiki.delete_page(page, commit_details)

    assert_equal 2, @wiki.repo.commits.size
    assert_nil @wiki.page("Gollum")
  end

  test "delete nested page" do
    index = @wiki.repo.index
    index.add("greek/Bilbo-Baggins.md", "hi")
    index.add("Gollum.md", "hi")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo-Baggins")
    assert page
    @wiki.delete_page(page, commit_details)

    assert_equal 2, @wiki.repo.commits.size
    assert_nil @wiki.page("Bilbo-Baggins")

    assert @wiki.page("Gollum")
  end

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
  end
end

context "Wiki sync with working directory" do
  setup do
    @path = testpath('examples/wdtest')
    Grit::Repo.init(@path)
    @wiki = Gollum::Wiki.new(@path)
  end

  test "write a page" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    assert_equal "Hi", File.read(File.join(@path, "New-Page.md"))
  end

  test "update a page with same name and format" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    page = @wiki.page("New Page")
    @wiki.update_page(page, page.name, page.format, "Bye", commit_details)
    assert_equal "Bye", File.read(File.join(@path, "New-Page.md"))
  end

  test "update a page with different name and same format" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    page = @wiki.page("New Page")
    @wiki.update_page(page, "New Page 2", page.format, "Bye", commit_details)
    assert_equal "Bye", File.read(File.join(@path, "New-Page-2.md"))
    assert !File.exist?(File.join(@path, "New-Page.md"))
  end

  test "update a page with same name and different format" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    page = @wiki.page("New Page")
    @wiki.update_page(page, page.name, :textile, "Bye", commit_details)
    assert_equal "Bye", File.read(File.join(@path, "New-Page.textile"))
    assert !File.exist?(File.join(@path, "New-Page.md"))
  end

  test "update a page with different name and different format" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    page = @wiki.page("New Page")
    @wiki.update_page(page, "New Page 2", :textile, "Bye", commit_details)
    assert_equal "Bye", File.read(File.join(@path, "New-Page-2.textile"))
    assert !File.exist?(File.join(@path, "New-Page.md"))
  end

  test "delete a page" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    page = @wiki.page("New Page")
    @wiki.delete_page(page, commit_details)
    assert !File.exist?(File.join(@path, "New-Page.md"))
  end

  teardown do
    FileUtils.rm_r(@path)
  end
end
