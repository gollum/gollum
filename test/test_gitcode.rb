# ~*~ encoding: utf-8 ~*~
require File.expand_path( '../helper', __FILE__ )
require File.expand_path( '../wiki_factory', __FILE__ )

context "gitcode" do

  def page_with_content c
    index = @wiki.repo.index
    index.add 'Sample-Html.md', c 
    index.commit 'adding file html sample'

    page = @wiki.page 'Sample Html'
    page
  end

  setup do
    # context
    @wiki, @path, @cleanup = WikiFactory.create 'examples/test.git'
  end

  test 'that the rendered output is correctly fetched and rendered as html code' do
    # given
    p = page_with_content "a\n\n```html:github:gollum/gollum/master/test/file_view/1_file.txt```\n\nb"

    # when rendering the page
    rendered = Gollum::Markup.new(p).render

    # we expect
    expected = %Q{<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"nt\">&lt;ol</span> <span class=\"na\">class=</span><span class=\"s\">\"tree\"</span><span class=\"nt\">&gt;</span>\n  <span class=\"nt\">&lt;li</span> <span class=\"na\">class=</span><span class=\"s\">\"file\"</span><span class=\"nt\">&gt;</span>\n    <span class=\"nt\">&lt;a</span> <span class=\"na\">href=</span><span class=\"s\">\"0\"</span><span class=\"nt\">&gt;&lt;span</span> <span class=\"na\">class=</span><span class=\"s\">\"icon\"</span><span class=\"nt\">&gt;&lt;/span&gt;</span>0<span class=\"nt\">&lt;/a&gt;</span>\n  <span class=\"nt\">&lt;/li&gt;</span>\n<span class=\"nt\">&lt;/ol&gt;</span>\n</pre></div>\n\n<p>b</p>}
    assert_equal expected, rendered
  end

  test 'contents' do
    g = Gollum::Gitcode.new 'gollum/gollum/master/test/file_view/1_file.txt'

    assert_equal g.contents, %{<ol class=\"tree\">\n  <li class=\"file\">\n    <a href=\"0\"><span class=\"icon\"></span>0</a>\n  </li>\n</ol>\n}
  end

  test "gitcode relative local file" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a\n```python:file-exists.py```\nb", commit_details)
    page = @wiki.page('Bilbo Baggins')

    index = @wiki.repo.index
    index.add("file-exists.py", "import sys\n\nprint sys.maxint\n")
    index.commit("Add file-exists.py")

    @wiki.clear_cache

    output = page.formatted_data
    assert_equal %Q{<p>a\n</p><div class="highlight"><pre><span class="kn">import</span> <span class="nn">sys</span>\n\n<span class="k">print</span> <span class="n">sys</span><span class="o">.</span><span class="n">maxint</span>\n</pre></div>\n\n<p>b</p>}, output
  end

  test "gitcode relative local file in subdir" do
    index = @wiki.repo.index
    index.add("foo/file-exists.py", "import sys\n\nprint sys.maxint\n")
    index.commit("Add file-exists.py")

    @wiki.write_page("Pippin", :markdown, "a\n```python:file-exists.py```\nb", commit_details, 'foo')

    page = @wiki.paged('Pippin', 'foo')
    output = page.formatted_data
    assert_equal %Q{<p>a\n</p><div class="highlight"><pre><span class="kn">import</span> <span class="nn">sys</span>\n\n<span class="k">print</span> <span class="n">sys</span><span class="o">.</span><span class="n">maxint</span>\n</pre></div>\n\n<p>b</p>}, output
  end

  test "gitcode relative no file" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a\n```python:no-file-exists.py```\nb", commit_details)
    page = @wiki.page('Bilbo Baggins')
    output = page.formatted_data
    assert_equal %Q{<p>a\nFile not found: no-file-exists.py\nb</p>}, output
  end

  test "gitcode absolute local file" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a\n```python:/monkey/file-exists.py```\nb", commit_details)
    page = @wiki.page('Bilbo Baggins')

    index = @wiki.repo.index
    index.add("monkey/file-exists.py", "import sys\n\nprint sys.platform\n")
    index.commit("Add monkey/file-exists.py")
    @wiki.clear_cache

    output = page.formatted_data
    assert_equal %Q{<p>a\n</p><div class="highlight"><pre><span class="kn">import</span> <span class="nn">sys</span>\n\n<span class="k">print</span> <span class="n">sys</span><span class="o">.</span><span class="n">platform</span>\n</pre></div>\n\n<p>b</p>}, output
  end

  test "gitcode absolute no file" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a\n```python:/monkey/no-file-exists.py```\nb", commit_details)
    page = @wiki.page('Bilbo Baggins')
    output = page.formatted_data
    assert_equal %Q{<p>a\nFile not found: /monkey/no-file-exists.py\nb</p>}, output
  end

  test "gitcode error generates santized html" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a\n```python:<script>foo</script>```\nb", commit_details)
    page = @wiki.page('Bilbo Baggins')
    output = page.formatted_data
    assert_equal %Q{<p>a\nFile not found: &lt;script&gt;foo&lt;/script&gt;\nb</p>}, output
  end

  teardown do
    @cleanup.call
  end
end
