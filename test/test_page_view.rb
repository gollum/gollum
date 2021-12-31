# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/page', __FILE__


context "Precious::Views::Page" do
  setup do
    @path    = cloned_testpath('examples/empty.git')
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "breadcrumbs guard against malicious input" do
    malicious_path = '<script>alert("malicious-content");/Very Bad'
    @wiki.write_page(malicious_path, :markdown, 'Is Bilbo a hobbit? Why certainly!')
    page = @wiki.page(malicious_path)
    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, false

    refute_includes @view.breadcrumb, malicious_path
    assert_includes @view.breadcrumb, ">&lt;script&gt;alert(&quot;malicious-content&quot;);</a>"
  end

  test "breadcrumbs retain unicode and ASCII characters" do
    path = "数学 📘/Age of Bilbo"
    @wiki.write_page(path, :markdown, "How old is Bilbo?")
    page = @wiki.page(path)
    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, false

    assert_includes @view.breadcrumb, "数学 📘"
  end

  test 'page <title> is the page header from content, if present' do
    page_title = 'Page header from content'
    @wiki.write_page(page_title, :markdown, 'Contents', commit_details)

    @view = Precious::Views::Page.new.tap do |view|
      view.instance_variable_set :@page, @wiki.page(page_title)
      view.instance_variable_set :@h1_title, true
    end

    assert_equal @view.title, 'Page header from content'
  end

  test 'page <title> is URL path title if no h1 present' do
    @wiki.write_page('dir/My path title', :markdown, 'Contents', commit_details)
    page = @wiki.page('dir/My path title')

    @view = Precious::Views::Page.new.tap do |view|
      view.instance_variable_set :@page, page
      view.instance_variable_set :@h1_title, false
    end

    assert_equal @view.title, 'My path title'
  end

  test "page header retains unicode and ASCII characters" do
    title = "数学 📘"
    @wiki.write_page(title, :markdown, "How old is Bilbo?")
    page = @wiki.page(title)
    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, false

    assert @view.page_header, "数学 📘"
  end

  test "h1 title sanitizes correctly" do
    title = 'H1'
    @wiki.write_page(title, :markdown, '# 1 & 2 <script>alert("js")</script>' + "\n # 3", commit_details)
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, true

    # Test page_header_from_content(@content)
    assert @view.page_header, "1 & 2"
  end

  test "page header uses filename when h1_title is false" do
    title = "H1"
    contents = <<~TEXT
      # First H1 header
      # Second H1 header
    TEXT

    @wiki.write_page(title, :markdown, contents, commit_details)
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, false

    assert_equal @view.page_header, "H1"
  end

  test "page header uses filename when h1_title is true" do
    contents = <<~TEXT
      # First H1 header
      # Second H1 header
    TEXT

    @wiki.write_page("H1", :markdown, contents, commit_details)
    page = @wiki.page("H1")

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, true

    assert_equal @view.page_header, "First H1 header"
  end



  test "metadata is rendered into a table" do
    title = 'metadata test'
    @wiki.write_page(title, :markdown, "---\nsome: metadata\nhere: for you\n---\n# Some markdown\nIn this doc")
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page

    assert_equal @view.rendered_metadata, <<-EOS
<table>
<tr>
<th>some</th>
<th>here</th>
</tr>
<tr>
<td>metadata</td>
<td>for you</td>
</tr>
</table>
EOS
  end

  test "allow numbered headings based on metadata" do
    title = 'header enumeration test'
    @wiki.write_page(title, :markdown, "---\nheader_enum: true\n---\n# Some markdown\nIn this doc")
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page

    assert_equal @view.header_enum?, true
    assert_equal @view.header_enum_style, 'decimal'

    title = 'header_enum test2'
    @wiki.write_page(title, :markdown, "---\nheader_enum: 'lower-roman'\n---\n# Some markdown\nIn this doc")
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page

    assert_equal @view.header_enum?, true
    assert_equal @view.header_enum_style, 'lower-roman'

    # With invalid style
    title = 'header_enum test3'
    @wiki.write_page(title, :markdown, "---\nheader_enum: 'roman'\n---\n# Some markdown\nIn this doc")
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page

    assert_equal @view.header_enum?, true
    assert_equal @view.header_enum_style, 'decimal'
  end

  test 'page has sha id' do
    title = 'test'
    @wiki.write_page(title, :markdown, 'Test' + "\n # 3", commit_details)
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    assert_equal "594e928cc5dcb6d833dfb86bb36076fd4a84eea7", @view.id
  end

  test "breadcrumbs" do
    @wiki.write_page('subdir/BC Test 1', :markdown, 'Test', commit_details)
    page = @wiki.page('subdir/BC Test 1')

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    assert_equal @view.breadcrumb, "<nav aria-label=\"Breadcrumb\"><ol>\n<li class=\"breadcrumb-item\"><a href=\"/gollum/overview/subdir/\">subdir</a></li>\n</ol></nav>"


    # No breadcrumb on unnested page
    @wiki.write_page('BC Test 2', :markdown, 'Test', commit_details)
    page = @wiki.page('BC Test 2')

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    assert_equal @view.breadcrumb, ''
  end

  test "body_side is 'right' by default" do
    @view = Precious::Views::Page.new
    assert_equal @view.body_side, "right"
  end

  test "body_side is 'left' if bar_side side is 'right'" do
    @view = Precious::Views::Page.new
    @view.instance_variable_set :@bar_side, :right
    assert_equal @view.body_side, "left"
  end

  test "links to pages containing ?" do
    @view = Precious::Views::Page.new
    assert_equal @view.page_route("Page?"), '/Page%3F'
  end
end
