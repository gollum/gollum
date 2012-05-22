# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Wiki" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
    Gollum::Wiki.markup_classes = nil
  end

  test "#markup_class gets default markup" do
    assert_equal Gollum::Markup, Gollum::Wiki.markup_class
  end

  test "#default_markup_class= doesn't clobber alternate markups" do
    custom = Class.new(Gollum::Markup)
    custom_md = Class.new(Gollum::Markup)

    Gollum::Wiki.markup_classes = Hash.new Gollum::Markup
    Gollum::Wiki.markup_classes[:markdown] = custom_md
    Gollum::Wiki.default_markup_class = custom

    assert_equal custom, Gollum::Wiki.default_markup_class
    assert_equal custom, Gollum::Wiki.markup_classes[:orgmode]
    assert_equal custom_md, Gollum::Wiki.markup_classes[:markdown]
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
      ['Bilbo-Baggins.md', 'Boromir.md', 'Eye-Of-Sauron.md', 'Home.textile', 'My-Precious.md', 'Samwise Gamgee.mediawiki'],
      pages.map { |p| p.filename }.sort
  end

  test "counts pages" do
    assert_equal 6, @wiki.size
  end

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

  test "gets reverse diff" do
    diff = @wiki.full_reverse_diff('a8ad3c09dd842a3517085bfadd37718856dee813')
    assert_match "b/Mordor/_Sidebar.md", diff
    assert_match "b/_Sidebar.md", diff
  end

  test "gets reverse diff for a page" do
    diff  = @wiki.full_reverse_diff_for('_Sidebar.md', 'a8ad3c09dd842a3517085bfadd37718856dee813')
    regex = /b\/Mordor\/\_Sidebar\.md/
    assert_match    "b/_Sidebar.md", diff
    assert_no_match regex, diff
  end
end

context "Wiki page previewing" do
  setup do
    @path = testpath("examples/lotr.git")
    Gollum::Wiki.default_options = {:universal_toc => false}
    @wiki = Gollum::Wiki.new(@path)
  end

  test "preview_page" do
    page = @wiki.preview_page("Test", "# Bilbo", :markdown)
    assert_equal "# Bilbo", page.raw_data
    assert_equal %Q{<h1>Bilbo<a class="anchor" id="Bilbo" href="#Bilbo"></a>\n</h1>}, page.formatted_data
    assert_equal "Test.md", page.filename
    assert_equal "Test", page.name
  end
end

context "Wiki TOC" do
  setup do
    @path = testpath("examples/lotr.git")
    options = {:universal_toc => true}
    @wiki = Gollum::Wiki.new(@path, options)
  end

  test "toc_generation" do
    page = @wiki.preview_page("Test", "# Bilbo", :markdown)
    assert_equal "# Bilbo", page.raw_data
    assert_equal '<h1>Bilbo<a class="anchor" id="Bilbo" href="#Bilbo"></a></h1>', page.formatted_data.gsub(/\n/,"")
    assert_equal %{<div class="toc"><div class="toc-title">Table of Contents</div><ul><li><a href="#Bilbo">Bilbo</a></li></ul></div>}, page.toc_data.gsub(/\n */,"")
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

context "Wiki page writing with whitespace (filename contains whitespace)" do
  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
  end

  test "update_page" do
    assert_equal :mediawiki, @wiki.page("Samwise Gamgee").format
    assert_equal "Samwise Gamgee.mediawiki", @wiki.page("Samwise Gamgee").filename

    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, page.name, :textile, "h1. Samwise Gamgee2", commit_details)

    assert_equal :textile, @wiki.page("Samwise Gamgee").format
    assert_equal "h1. Samwise Gamgee2", @wiki.page("Samwise Gamgee").raw_data
    assert_equal "Samwise Gamgee.textile", @wiki.page("Samwise Gamgee").filename
  end

  test "update page with format change, verify non-canonicalization of filename,  where filename contains Whitespace" do
    assert_equal :mediawiki, @wiki.page("Samwise Gamgee").format
    assert_equal "Samwise Gamgee.mediawiki", @wiki.page("Samwise Gamgee").filename

    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, page.name, :textile, "h1. Samwise Gamgee", commit_details)

    assert_equal :textile, @wiki.page("Samwise Gamgee").format
    assert_equal "h1. Samwise Gamgee", @wiki.page("Samwise Gamgee").raw_data
    assert_equal "Samwise Gamgee.textile", @wiki.page("Samwise Gamgee").filename
  end

  test "update page with name change, verify canonicalization of filename, where filename contains Whitespace" do
    assert_equal :mediawiki, @wiki.page("Samwise Gamgee").format
    assert_equal "Samwise Gamgee.mediawiki", @wiki.page("Samwise Gamgee").filename

    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, 'Sam Gamgee', :textile, "h1. Samwise Gamgee", commit_details)

    assert_equal "h1. Samwise Gamgee", @wiki.page("Sam Gamgee").raw_data
    assert_equal "Sam-Gamgee.textile", @wiki.page("Sam Gamgee").filename
  end

  test "update page with name and format change, verify canonicalization of filename, where filename contains Whitespace" do
    assert_equal :mediawiki, @wiki.page("Samwise Gamgee").format
    assert_equal "Samwise Gamgee.mediawiki", @wiki.page("Samwise Gamgee").filename

    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, 'Sam Gamgee', :textile, "h1. Samwise Gamgee", commit_details)

    assert_equal :textile, @wiki.page("Sam Gamgee").format
    assert_equal "h1. Samwise Gamgee", @wiki.page("Sam Gamgee").raw_data
    assert_equal "Sam-Gamgee.textile", @wiki.page("Sam Gamgee").filename
  end

  teardown do
    FileUtils.rm_rf(@path)
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

context "Wiki sync with working directory (filename contains whitespace)" do
  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
  end
  test "update a page with same name and format" do
    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, page.name, page.format, "What we need is a few good taters.", commit_details)
    assert_equal "What we need is a few good taters.", File.read(File.join(@path, "Samwise Gamgee.mediawiki"))
  end

  test "update a page with different name and same format" do
    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, "Sam Gamgee", page.format, "What we need is a few good taters.", commit_details)
    assert_equal "What we need is a few good taters.", File.read(File.join(@path, "Sam-Gamgee.mediawiki"))
    assert !File.exist?(File.join(@path, "Samwise Gamgee"))
  end

  test "update a page with same name and different format" do
    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, page.name, :textile, "What we need is a few good taters.", commit_details)
    assert_equal "What we need is a few good taters.", File.read(File.join(@path, "Samwise Gamgee.textile"))
    assert !File.exist?(File.join(@path, "Samwise Gamgee.mediawiki"))
  end

  test "update a page with different name and different format" do
    page = @wiki.page("Samwise Gamgee")
    @wiki.update_page(page, "Sam Gamgee", :textile, "What we need is a few good taters.", commit_details)
    assert_equal "What we need is a few good taters.", File.read(File.join(@path, "Sam-Gamgee.textile"))
    assert !File.exist?(File.join(@path, "Samwise Gamgee.mediawiki"))
  end

  test "delete a page" do
    page = @wiki.page("Samwise Gamgee")
    @wiki.delete_page(page, commit_details)
    assert !File.exist?(File.join(@path, "Samwise Gamgee.mediawiki"))
  end

  teardown do
    FileUtils.rm_r(@path)
  end
end

context "page_file_dir option" do
  setup do
    @path = cloned_testpath('examples/page_file_dir')
    @repo = Grit::Repo.init(@path)
    @page_file_dir = 'docs'
    @wiki = Gollum::Wiki.new(@path, :page_file_dir => @page_file_dir)
  end

  test "write a page in sub directory" do
    @wiki.write_page("New Page", :markdown, "Hi", commit_details)
    assert_equal "Hi", File.read(File.join(@path, @page_file_dir, "New-Page.md"))
    assert !File.exist?(File.join(@path, "New-Page.md"))
  end

  test "edit a page in a sub directory" do
    page = @wiki.page('foo')
    @wiki.update_page(page, page.name, page.format, 'new contents', commit_details)
  end

  test "a file in page file dir should be found" do
    assert @wiki.page("foo")
  end

  test "a file out of page file dir should not be found" do
    assert !@wiki.page("bar")
  end

  test "search results should be restricted in page filer dir" do
    results = @wiki.search("foo")
    assert_equal 1, results.size
    assert_equal "foo", results[0][:name]
  end

  teardown do
    FileUtils.rm_r(@path)
  end
end

context "Wiki page writing with different branch" do
  setup do
    @path = testpath("examples/test.git")
    FileUtils.rm_rf(@path)
    @repo = Grit::Repo.init_bare(@path)
    @wiki = Gollum::Wiki.new(@path)

    # We need an initial commit to create the master branch
    # before we can create new branches
    cd = commit_details
    @wiki.write_page("Gollum", :markdown, "# Gollum", cd)

    # Create our test branch and check it out
    @repo.update_ref("test", @repo.commits.first.id)
    @branch = Gollum::Wiki.new(@path, :ref => "test")
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "write_page" do
    cd = commit_details

    @branch.write_page("Bilbo", :markdown, "# Bilbo", commit_details)
    assert @branch.page("Bilbo")
    assert @wiki.page("Gollum")

    assert_equal 1, @wiki.repo.commits.size
    assert_equal 1, @branch.repo.commits.size

    assert_equal nil, @wiki.page("Bilbo")
  end
end
