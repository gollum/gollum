# ~*~ encoding: utf-8 ~*~
require File.expand_path( "../helper", __FILE__ )
require File.expand_path( "../wiki_factory", __FILE__ )

context "Markup" do
  setup do
    @wiki, @path, @teardown = WikiFactory.create 'examples/test.git'
  end

  teardown do
    @teardown.call
  end

  test "formats page from Wiki#pages" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Foo]][[Bar]] b", commit_details)
    assert @wiki.pages[0].formatted_data
  end

  # This test is to assume that Sanitize.clean doesn't raise Encoding::CompatibilityError on ruby 1.9
  test "formats non ASCII-7 character page from Wiki#pages" do
    wiki = Gollum::Wiki.new(testpath("examples/yubiwa.git"))
    assert_nothing_raised(defined?(Encoding) && Encoding::CompatibilityError) do
      assert wiki.page("strider").formatted_data
    end
  end

  test "Gollum::Markup#render yields a DocumentFragment" do
    yielded = false
    @wiki.write_page("Yielded", :markdown, "abc", commit_details)

    page   = @wiki.page("Yielded")
    markup = Gollum::Markup.new(page)
    markup.render do |doc|
      assert_kind_of Nokogiri::HTML::DocumentFragment, doc
      yielded = true
    end
    assert yielded
  end

  test "Gollum::Page#formatted_data yields a DocumentFragment" do
    yielded = false
    @wiki.write_page("Yielded", :markdown, "abc", commit_details)

    page   = @wiki.page("Yielded")
    page.formatted_data do |doc|
      assert_kind_of Nokogiri::HTML::DocumentFragment, doc
      yielded = true
    end
    assert yielded
  end

  #########################################################################
  #
  # Links
  #
  #########################################################################

  test "absolute link to non-existent page" do
    @wiki.write_page("linktest", :markdown, "[[/Page]]", commit_details)

    page    = @wiki.page("linktest")
    doc     = Nokogiri::HTML page.formatted_data
    paras   = doc / :p
    para    = paras.first
    anchors = para / :a
    assert_equal 1, paras.size
    assert_equal 1, anchors.size
    assert_equal 'internal absent', anchors[0]['class']
    assert_equal '/Page',           anchors[0]['href']
    assert_equal '/Page',           anchors[0].text
  end

  test "double page links no space" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Foo]][[Bar]] b", commit_details)

    # "<p>a <a class=\"internal absent\" href=\"/Foo\">Foo</a><a class=\"internal absent\" href=\"/Bar\">Bar</a> b</p>"
    page    = @wiki.page("Bilbo Baggins")
    doc     = Nokogiri::HTML page.formatted_data
    paras   = doc / :p
    para    = paras.first
    anchors = para / :a
    assert_equal 1, paras.size
    assert_equal 2, anchors.size
    assert_equal 'internal absent', anchors[0]['class']
    assert_equal 'internal absent', anchors[1]['class']
    assert_equal '/Foo',            anchors[0]['href']
    assert_equal '/Bar',            anchors[1]['href']
    assert_equal 'Foo',             anchors[0].text
    assert_equal 'Bar',             anchors[1].text
  end

  test "double page links with space" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Foo]] [[Bar]] b", commit_details)

    # "<p>a <a class=\"internal absent\" href=\"/Foo\">Foo</a> <a class=\"internal absent\" href=\"/Bar\">Bar</a> b</p>"
    page = @wiki.page("Bilbo Baggins")
    doc     = Nokogiri::HTML page.formatted_data
    paras   = doc / :p
    para    = paras.first
    anchors = para / :a
    assert_equal 1, paras.size
    assert_equal 2, anchors.size
    assert_equal 'internal absent', anchors[0]['class']
    assert_equal 'internal absent', anchors[1]['class']
    assert_equal '/Foo',            anchors[0]['href']
    assert_equal '/Bar',            anchors[1]['href']
    assert_equal 'Foo',             anchors[0].text
    assert_equal 'Bar',             anchors[1].text
  end

  test "page link" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Bilbo Baggins]] b", commit_details)

    page = @wiki.page("Bilbo Baggins")
    output = page.formatted_data
    assert_match /class="internal present"/, output
    assert_match /href="\/Bilbo-Baggins"/,   output
    assert_match /\>Bilbo Baggins\</,        output
  end

  test "adds nofollow to links on historical pages" do
    sha1 = @wiki.write_page("Sauron", :markdown, "a [[b]] c", commit_details)
    page = @wiki.page("Sauron")
    sha2 = @wiki.update_page(page, page.name, :markdown, "c [[b]] a", commit_details)
    regx = /rel="nofollow"/
    assert_no_match regx, page.formatted_data
    assert_match    regx, @wiki.page(page.name, sha1).formatted_data
    assert_match    regx, @wiki.page(page.name, sha2).formatted_data
  end

  test "absent page link" do
    @wiki.write_page("Tolkien", :markdown, "a [[J. R. R. Tolkien]]'s b", commit_details)

    page = @wiki.page("Tolkien")
    output = page.formatted_data
    assert_match /class="internal absent"/,         output
    assert_match /href="\/J\.\-R\.\-R\.\-Tolkien"/, output
    assert_match /\>J\. R\. R\. Tolkien\</,         output
  end

  test "page link with custom base path" do
    ["/wiki", "/wiki/"].each_with_index do |path, i|
      name = "Bilbo Baggins #{i}"
      @wiki = Gollum::Wiki.new(@path, :base_path => path)
      @wiki.write_page(name, :markdown, "a [[#{name}]] b", commit_details)

      page = @wiki.page(name)
      output = page.formatted_data
      assert_match /class="internal present"/,        output
      assert_match /href="\/wiki\/Bilbo-Baggins-\d"/, output
      assert_match /\>Bilbo Baggins \d\</,            output
    end
  end

  test "page link with included #" do
    @wiki.write_page("Precious #1", :markdown, "a [[Precious #1]] b", commit_details)
    page   = @wiki.page('Precious #1')
    output = page.formatted_data
    assert_match /class="internal present"/, output
    assert_match /href="\/Precious-%231"/,   output
  end

  test "page link with extra #" do
    @wiki.write_page("Potato", :markdown, "a [[Potato#1]] b", commit_details)
    page   = @wiki.page('Potato')
    output = page.formatted_data
    assert_match /class="internal present"/, output
    assert_match /href="\/Potato#1"/,        output
  end

  test "external page link" do
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[http://example.com]] b", commit_details)

    page = @wiki.page("Bilbo Baggins")
    assert_equal "<p>a <a href=\"http://example.com\">http://example.com</a> b</p>", page.formatted_data
  end

  test "page link with different text" do
    @wiki.write_page("Potato", :markdown, "a [[Potato Heaad|Potato]] ", commit_details)
    page = @wiki.page("Potato")
    output = page.formatted_data
    assert_equal "<p>a<aclass=\"internalpresent\"href=\"/Potato\">PotatoHeaad</a></p>", normal(output)
  end

  test "page link with different text on mediawiki" do
    @wiki.write_page("Potato", :mediawiki, "a [[Potato|Potato Heaad]] ", commit_details)
    page = @wiki.page("Potato")
    output = page.formatted_data
    assert_equal normal("<p>\na <a class=\"internal present\" href=\"/Potato\">Potato Heaad</a> </p>
"), normal(output)
  end

  test "wiki link within inline code block" do
    @wiki.write_page("Potato", :markdown, "`sed -i '' 's/[[:space:]]*$//'`", commit_details)
    page = @wiki.page("Potato")
    assert_equal "<p><code>sed -i '' 's/[[:space:]]*$//'</code></p>", page.formatted_data
  end

  test "regexp gsub! backref (#383)" do
    # bug only triggers on "```" syntax
    # not `code`
    page = 'test_rgx'
    @wiki.write_page(page, :markdown,
      (<<-'DATA'
          ```
          rot13='tr '\''A-Za-z'\'' '\''N-ZA-Mn-za-m'\'
          ```
          DATA
      ), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %Q{<pre><code>      <div class=\"highlight\"><pre><span class=\"n\">rot13</span><span class=\"p\">=</span><span class=\"s\">'tr '</span><span class=\"o\">\\</span><span class=\"s\">''</span><span class=\"n\">A</span><span class=\"o\">-</span><span class=\"n\">Za</span><span class=\"o\">-</span><span class=\"n\">z</span><span class=\"o\">'\\</span><span class=\"s\">''</span> <span class=\"s\">'\\''N-ZA-Mn-za-m'</span><span class=\"o\">\\</span><span class=\"s\">'</span>\n</pre></div>\n</code></pre>}
    assert_equal expected, output
  end

  # Issue #568
  test "tilde code blocks without a language" do
    page = 'test_rgx'
    @wiki.write_page(page, :markdown,
      %Q(~~~
'hi'
~~~
      ), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %Q{<div class=\"highlight\"><pre><span class=\"s\">'hi'</span>\n</pre></div>}
    assert_equal expected, output
  end

  test "tilde code blocks #537" do
    page = 'test_rgx'
    @wiki.write_page(page, :markdown,
      %Q(~~~ {.ruby}
'hi'
~~~
      ), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %Q{<div class=\"highlight\"><pre><span class=\"s1\">'hi'</span>\n</pre></div>}
    assert_equal expected, output
  end

  # Issue #537
  test "tilde code blocks with more than one class" do
    page = 'test_rgx'
    @wiki.write_page(page, :markdown,
      %Q(~~~ {#hi .ruby .sauce}
'hi'
~~~
      ), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %Q{<div class=\"highlight\"><pre><span class=\"s1\">'hi'</span>\n</pre></div>}
    assert_equal expected, output
  end

  # Issue #537
  test "tilde code blocks with lots of tildes" do
    page = 'test_rgx'
    @wiki.write_page(page, :markdown,
      %Q(~~~~~~ {#hi .ruby .sauce}
~~
'hi'~
~~~~~~
      ), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %Q{<div class=\"highlight\"><pre><span class=\"o\">~~</span>\n<span class=\"s1\">'hi'</span><span class=\"o\">~</span>\n</pre></div>}
    assert_equal expected, output
  end

  test "four space indented code block" do
    page = 'test_four'
    @wiki.write_page(page, :markdown,
      %(    test
    test), commit_details)
    output = @wiki.page(page).formatted_data
    expected = %(<pre><code>test\ntest\n</code></pre>)
    assert_equal expected, output
  end

  test "wiki link within code block" do
    @wiki.write_page("Potato", :markdown, "    sed -i '' 's/[[:space:]]*$//'", commit_details)
    page = @wiki.page("Potato")
    assert_equal "<pre><code>sed -i '' 's/[[:space:]]*$//'\n</code></pre>", page.formatted_data
  end

  test "piped wiki link within code block" do
    @wiki.write_page("Potato", :markdown, "`make a link [[home|sweet home]]`", commit_details)
    page = @wiki.page("Potato")
    assert_equal "<p><code>make a link [[home|sweet home]]</code></p>", page.formatted_data
  end

  #########################################################################
  #
  # Images
  #
  #########################################################################

  test "image with http url" do
    ['http', 'https'].each do |scheme|
      name = "Bilbo Baggins #{scheme}"
      @wiki.write_page(name, :markdown, "a [[#{scheme}://example.com/bilbo.jpg]] b", commit_details)

      page = @wiki.page(name)
      output = page.formatted_data
      assert_equal %{<p>a <img src=\"#{scheme}://example.com/bilbo.jpg\" /> b</p>}, output
    end
  end

  test "image with extension in caps with http url" do
    ['http', 'https'].each do |scheme|
      name = "Bilbo Baggins #{scheme}"
      @wiki.write_page(name, :markdown, "a [[#{scheme}://example.com/bilbo.JPG]] b", commit_details)

      page = @wiki.page(name)
      output = page.formatted_data
      assert_equal %{<p>a <img src=\"#{scheme}://example.com/bilbo.JPG\" /> b</p>}, output
    end
  end

  test "image with absolute path" do
    @wiki = Gollum::Wiki.new(@path, :base_path => '/wiki')
    index = @wiki.repo.index
    index.add("alpha.jpg", "hi")
    index.commit("Add alpha.jpg")
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[/alpha.jpg]] [[a | /alpha.jpg]] b", commit_details)

    page = @wiki.page("Bilbo Baggins")
    assert_equal %{<p>a <img src=\"/wiki/alpha.jpg\" /><a href=\"/wiki/alpha.jpg\">a</a> b</p>}, page.formatted_data
  end

  test "image with relative path on root" do
    @wiki = Gollum::Wiki.new(@path, :base_path => '/wiki')
    index = @wiki.repo.index
    index.add("alpha.jpg", "hi")
    index.add("Bilbo-Baggins.md", "a [[alpha.jpg]] [[a | alpha.jpg]] b")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    assert_equal %Q{<p>a <img src=\"/wiki/alpha.jpg\" /><a href=\"/wiki/alpha.jpg\">a</a> b</p>}, page.formatted_data
  end

  test "image with relative path" do
    @wiki = Gollum::Wiki.new(@path, :base_path => '/wiki')
    index = @wiki.repo.index
    index.add("greek/alpha.jpg", "hi")
    index.add("greek/Bilbo-Baggins.md", "a [[alpha.jpg]] [[a | alpha.jpg]] b")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    output = page.formatted_data
    assert_equal %{<p>a <img src=\"/wiki/greek/alpha.jpg\" /><a href=\"/wiki/greek/alpha.jpg\">a</a> b</p>}, output
  end

  test "image with absolute path on a preview" do
    @wiki = Gollum::Wiki.new(@path, :base_path => '/wiki')
    index = @wiki.repo.index
    index.add("alpha.jpg", "hi")
    index.commit("Add alpha.jpg")

    page = @wiki.preview_page("Test", "a [[/alpha.jpg]] b", :markdown)
    assert_equal %{<p>a <img src=\"/wiki/alpha.jpg\" /> b</p>}, page.formatted_data
  end

  test "image with relative path on a preview" do
    @wiki = Gollum::Wiki.new(@path, :base_path => '/wiki')
    index = @wiki.repo.index
    index.add("alpha.jpg", "hi")
    index.add("greek/alpha.jpg", "hi")
    index.commit("Add alpha.jpg")

    page = @wiki.preview_page("Test", "a [[alpha.jpg]] [[greek/alpha.jpg]] b", :markdown)
    assert_equal %{<p>a <img src=\"/wiki/alpha.jpg\" /><img src=\"/wiki/greek/alpha.jpg\" /> b</p>}, page.formatted_data
  end

  test "image with alt" do
    content = "a [[alpha.jpg|alt=Alpha Dog]] b"
    output = %{<p>a<imgsrc=\"/greek/alpha.jpg\"alt=\"AlphaDog\"/>b</p>}
    relative_image(content, output)
  end

  test "image with em or px dimension" do
    %w{em px}.each do |unit|
      %w{width height}.each do |dim|
        content = "a [[alpha.jpg|#{dim}=100#{unit}]] b"
        output = "<p>a<imgsrc=\"/greek/alpha.jpg\"#{dim}=\"100#{unit}\"/>b</p>"
        relative_image(content, output)
      end
    end
  end

  test "image with bogus dimension" do
    %w{width height}.each do |dim|
      content = "a [[alpha.jpg|#{dim}=100]] b"
      output = "<p>a<imgsrc=\"/greek/alpha.jpg\"/>b</p>"
      relative_image(content, output)
    end
  end

  test "image with vertical align" do
    %w{top texttop middle absmiddle bottom absbottom baseline}.each do |align|
      content = "a [[alpha.jpg|align=#{align}]] b"
      output = %Q{<p>a<imgsrc=\"/greek/alpha.jpg\"align=\"#{align}\"/>b</p>}
      relative_image(content, output)
    end
  end

  test "image with horizontal align" do
    %w{left center right}.each do |align|
      content = "a [[alpha.jpg|align=#{align}]] b"
      output = "<p>a<spanclass=\"align-#{align}\"><span><imgsrc=\"/greek/alpha.jpg\"/></span></span>b</p>"
      relative_image(content, output)
    end
  end

  test "image with float" do
    content = "a\n\n[[alpha.jpg|float]]\n\nb"
    output = "<p>a</p><p><spanclass=\"float-left\"><span><imgsrc=\"/greek/alpha.jpg\"/></span></span></p><p>b</p>"
    relative_image(content, output)
  end

  test "image with float and align" do
    %w{left right}.each do |align|
      content = "a\n\n[[alpha.jpg|float|align=#{align}]]\n\nb"
      output = "<p>a</p><p><spanclass=\"float-#{align}\"><span><imgsrc=\"/greek/alpha.jpg\"/></span></span></p><p>b</p>"
      relative_image(content, output)
    end
  end

  test "image with frame" do
    content = "a\n\n[[alpha.jpg|frame]]\n\nb"
    output = "<p>a</p><p><spanclass=\"frame\"><span><imgsrc=\"/greek/alpha.jpg\"/></span></span></p><p>b</p>"
    relative_image(content, output)
  end

  test "absolute image with frame" do
    content = "a\n\n[[http://example.com/bilbo.jpg|frame]]\n\nb"
    output = "<p>a</p><p><spanclass=\"frame\"><span><imgsrc=\"http://example.com/bilbo.jpg\"/></span></span></p><p>b</p>"
    relative_image(content, output)
  end

  test "image with frame and alt" do
    content = "a\n\n[[alpha.jpg|frame|alt=Alpha]]\n\nb"
    output = "<p>a</p><p><spanclass=\"frame\"><span><imgsrc=\"/greek/alpha.jpg\"alt=\"Alpha\"/><span>Alpha</span></span></span></p><p>b</p>"
    relative_image(content, output)
  end

  #########################################################################
  #
  # File links
  #
  #########################################################################

  test "file link with absolute path" do
    index = @wiki.repo.index
    index.add("alpha.jpg", "hi")
    index.commit("Add alpha.jpg")
    @wiki.write_page("Bilbo Baggins", :markdown, "a [[Alpha|/alpha.jpg]] b", commit_details)

    page = @wiki.page("Bilbo Baggins")
    output = Gollum::Markup.new(page).render
    assert_equal %{<p>a <a href="/alpha.jpg">Alpha</a> b</p>}, output
  end

  test "file link with relative path" do
    index = @wiki.repo.index
    index.add("greek/alpha.jpg", "hi")
    index.add("greek/Bilbo-Baggins.md", "a [[Alpha|alpha.jpg]] b")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    output = Gollum::Markup.new(page).render
    assert_equal %{<p>a <a href="/greek/alpha.jpg">Alpha</a> b</p>}, output
  end

  test "file link with external path" do
    index = @wiki.repo.index
    index.add("greek/Bilbo-Baggins.md", "a [[Alpha|http://example.com/alpha.jpg]] b")
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    assert_equal %{<p>a <a href="http://example.com/alpha.jpg">Alpha</a> b</p>}, page.formatted_data
  end

  #########################################################################
  #
  # Code
  #
  #########################################################################

  test "regular code blocks" do
    content = "a\n\n```ruby\nx = 1\n```\n\nb"
    output = %Q{<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"n\">x</span> <span class=\"o\">=</span> <span class=\"mi\">1</span>\n</pre></div>\n\n<p>b</p>}

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal output, rendered
  end

  test "code blocks with carriage returns" do
    content = "a\r\n\r\n```ruby\r\nx = 1\r\n```\r\n\r\nb"
    output = %Q{<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"n\">x</span> <span class=\"o\">=</span> <span class=\"mi\">1</span>\n</pre></div>\n\n<p>b</p>}

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal output, rendered
  end

  test "code blocks with two-space indent" do
    content = "a\n\n```ruby\n  x = 1\n\n  y = 2\n```\n\nb"
    output = "<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"n\">" +
             "x</span> <span class=\"o\">=</span> <span class=\"mi\">1" +
             "</span>\n\n<span class=\"n\">y</span> <span class=\"o\">=" +
             "</span> <span class=\"mi\">2</span>\n</pre>\n</div>\n\n\n<p>b</p>"
    compare(content, output)
  end

  test "code blocks with one-tab indent" do
    content = "a\n\n```ruby\n\tx = 1\n\n\ty = 2\n```\n\nb"
    output = "<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"n\">" +
             "x</span> <span class=\"o\">=</span> <span class=\"mi\">1" +
             "</span>\n\n<span class=\"n\">y</span> <span class=\"o\">=" +
             "</span> <span class=\"mi\">2</span>\n</pre>\n</div>\n\n\n<p>b</p>"
    compare(content, output)
  end

  test "code blocks with multibyte caracters indent" do
    content = "a\n\n```ruby\ns = 'やくしまるえつこ'\n```\n\nb"
    output = %Q{<p>a</p>\n\n<div class=\"highlight\"><pre><span class=\"n\">s</span> <span class=\"o\">=</span> <span class=\"s1\">'やくしまるえつこ'</span>\n</pre></div>\n\n<p>b</p>}
    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add alpha.jpg")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render(false, 'utf-8')
    assert_equal output, rendered
  end

  test "code blocks with ascii characters" do
    content = "a\n\n```\n├─foo\n```\n\nb"
    output = "<p>a</p>\n\n<div class=\"highlight\"><pre>" +
             "├─<span class=\"n\">foo</span>" +
             "\n</pre>\n</div>\n\n<p>b</p>"
    compare(content, output)
  end

  test "code with wiki links" do
    content = <<-END
booya

``` python
np.array([[2,2],[1,3]],np.float)
```
    END

    # rendered with Gollum::Markup
    page, rendered = render_page(content)
    assert_markup_highlights_code Gollum::Markup, rendered
  end

  test "code with trailing whitespace" do
    content = <<-END
shoop da woop

``` python 
np.array([[2,2],[1,3]],np.float)
```
    END

    # rendered with Gollum::Markup
    page, rendered = render_page(content)
    assert_markup_highlights_code Gollum::Markup, rendered
  end

  def assert_markup_highlights_code(markup_class, rendered)
    assert_match /div class="highlight"/, rendered, "#{markup_class} doesn't highlight code\n #{rendered}"
    assert_match /span class="n"/, rendered, "#{markup_class} doesn't highlight code\n #{rendered}"
    assert_match /\(\[\[/, rendered, "#{markup_class} parses out wiki links\n#{rendered}"
  end

  test "embed code page absolute link" do
    @wiki.write_page("base", :markdown, "a\n!base\b", commit_details)
    @wiki.write_page("a", :markdown, "a\n```html:/base```\b", commit_details)

    page = @wiki.page("a")
    output = page.formatted_data
    assert_equal %Q{<p>a\nFile not found: /base</p>}, output
  end

  test "embed code page relative link" do
    @wiki.write_page("base", :markdown, "a\n!rel\b", commit_details)
    @wiki.write_page("a", :markdown, "a\n```html:base```\b", commit_details)

    page = @wiki.page("a")
    output = page.formatted_data
    assert_equal %Q{<p>a\nFile not found: base</p>}, output
  end

  test "code block in unsupported language" do
    @wiki.write_page("a", :markdown, "a\n```nonexistent\ncode\n```\nb", commit_details)

    page = @wiki.page("a")
    output = page.formatted_data
    assert_equal %Q{<p>a\ncode\nb</p>}, output
  end

  #########################################################################
  #
  # Web Sequence Diagrams
  #
  #########################################################################

  test "sequence diagram blocks" do
    content = "a\n\n{{{{{{default\nalice->bob: Test\n}}}}}}\n\nb"
    output = /.*<img src="http:\/\/www\.websequencediagrams\.com\/\?img=\w{9}" \/>.*/

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add sequence diagram")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_not_nil rendered.match(output)
  end

  #########################################################################
  #
  # Metadata Blocks
  #
  #########################################################################

  test "metadata blocks" do
    content = "a\n\n<!-- ---\ntags: [foo, bar]\n-->\n\nb"
    output = "<p>a</p>\n\n<p>b</p>"
    result = {'tags'=>['foo','bar']}

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add metadata")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal output, rendered 
    assert_equal result, page.metadata
  end

  test "metadata blocks with newline" do
    content = "a\n\n<!--\n---\ntags: [foo, bar]\n-->\n\nb"
    output = "<p>a</p>\n\n<p>b</p>"
    result = {'tags'=>['foo','bar']}

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add metadata")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal output, rendered 
    assert_equal result, page.metadata
  end

  test "metadata sanitation" do
    content = "a\n\n<!-- ---\nfoo: <script>alert('');</script>\n-->\n\nb"
    output = "<p>a</p>\n\n<p>b</p>"
    result = {'foo'=>nil}

    index = @wiki.repo.index
    index.add("Bilbo-Baggins.md", content)
    index.commit("Add metadata")

    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal output, rendered 
    assert_equal result, page.metadata
  end

  #########################################################################
  #
  # Various
  #
  #########################################################################

  test "strips javscript protocol urls" do
    content = "[Hack me](javascript:hacked=true)"
    output = "<p><a>Hackme</a></p>"
    compare(content, output)
  end

  test "allows apt uri schemes" do
    content = "[Hack me](apt:gettext)"
    output = "<p><a href=\"apt:gettext\">Hackme</a></p>"
    compare(content, output)
  end

  test "removes style blocks completely" do
    content = "<style>body { color: red }</style>foobar"
    output = "<p>foobar</p>"
    compare(content, output)
  end

  test "removes script blocks completely" do
    content = "<script>alert('hax');</script>foobar"
    output = "<p>foobar</p>"
    compare(content, output)
  end

  test "escaped wiki link" do
    content = "a '[[Foo]], b"
    output = "<p>a [[Foo]], b</p>"
    compare(content, output)
  end

  test "quoted wiki link" do
    content = "a '[[Foo]]', b"
    output = "<p>a '<a class=\"internal absent\" href=\"/Foo\">Foo</a>', b</p>"
    compare(content, output, 'md', [
      /class="internal absent"/,
      /href="\/Foo"/,
      /\>Foo\</])
  end

  test "org mode style double links" do
    content = "a [[http://google.com][Google]] b"
    output = "<p class=\"title\">a <a href=\"http://google.com\">Google</a> b</p>"
    compare(content, output, 'org')
  end

  test "org mode style double file links" do
    content = "a [[file:f.org][Google]] b"
    output = "<p class=\"title\">a <a class=\"internal absent\" href=\"/f\">Google</a> b</p>"
    compare(content, output, 'org')
  end

  test "short double links" do
    content = "a [[b]] c"
    output  = %(<p class="title">a <a class="internal absent" href="/b">b</a> c</p>)
    compare(content, output, 'org')
  end

  test "double linked pipe" do
    content = "a [[|]] b"
    output  = %(<p class="title">a <a class="internal absent" href="/"></a> b</p>)
    compare(content, output, 'org')
  end

  test "id with prefix ok" do
    content = "h2(example#wiki-foo). xxxx"
output = %(<h2 class="example" id="wiki-foo">xxxx<a class=\"anchor\" id=\"xxxx\" href=\"#xxxx\"></a></h2>)
compare(content, output, :textile)
end

  test "id prefix added" do
    content = "h2(#foo). xxxx[1]\n\nfn1.footnote"
    output = "<h2 id=\"wiki-foo\">xxxx" +
             "<sup class=\"footnote\" id=\"wiki-fnr1\"><a href=\"#wiki-fn1\">1</a></sup>" +
             "<a class=\"anchor\" id=\"xxxx1\" href=\"#xxxx1\"></a></h2>" +
             "\n<p class=\"footnote\" id=\"wiki-fn1\"><a href=\"#wiki-fnr1\"><sup>1</sup></a> footnote</p>"
    compare(content, output, :textile)
  end

  test "name prefix added" do
    content = "abc\n\n__TOC__\n\n==Header==\n\nblah"
    compare content, '', :mediawiki, [
      /id="wiki-toc"/,
      /href="#wiki-Header"/,
      /id="wiki-Header"/,
      /name="wiki-Header"/
    ]
  end

if ENV['ASCIIDOC']
  #########################################################################
  # Asciidoc
  #########################################################################

  test "asciidoc header" do 
    compare("= Book Title\n\n== Heading", '<div class="sect1"><h2 id="wiki-_heading">Heading<a class="anchor" id="Heading" href="#Heading"></a></h2><div class="sectionbody"></div></div>', 'asciidoc')
  end

  test "internal links with asciidoc" do 
    compare("= Book Title\n\n[[anid]]\n== Heading", '<div class="sect1"><h2 id="wiki-anid">Heading<a class="anchor" id="Heading" href="#Heading"></a></h2><div class="sectionbody"></div></div>', 'asciidoc')
  end
end

  #########################################################################
  #
  # Helpers
  #
  #########################################################################

  def render_page(content, ext = "md")
    index = @wiki.repo.index
    index.add("Bilbo-Baggins.#{ext}", content)
    index.commit("Add baggins")

    page = @wiki.page("Bilbo Baggins")
    [page, Gollum::Markup.new(page).render]
  end

  def compare(content, output, ext = "md", regexes = [])
    page, rendered = render_page(content, ext)

    if regexes.empty?
      assert_equal normal(output), normal(rendered)
    else
      output = page.formatted_data
      regexes.each { |r| assert_match r, output }
    end
  end

  def relative_image(content, output)
    index = @wiki.repo.index
    index.add("greek/alpha.jpg", "hi")
    index.add("greek/Bilbo-Baggins.md", content)
    index.commit("Add alpha.jpg")

    @wiki.clear_cache
    page = @wiki.page("Bilbo Baggins")
    rendered = Gollum::Markup.new(page).render
    assert_equal normal(output), normal(rendered)
  end
end
