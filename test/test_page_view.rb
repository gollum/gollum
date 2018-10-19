# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/page', __FILE__

context "Precious::Views::Page" do
  setup do
    examples = testpath "examples"
    @path    = File.join(examples, "test.git")
    FileUtils.cp_r File.join(examples, "empty.git"), @path, :remove_destination => true
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_r(File.join(File.dirname(__FILE__), *%w[examples test.git]))
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
    actual = @view.title
    assert_equal '1 & 2', actual
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

  test "h1 title can be disabled" do
    title = 'H1'
    @wiki.write_page(title, :markdown, '# 1 & 2 <script>alert("js")</script>' + "\n # 3", commit_details)
    page = @wiki.page(title)

    @view = Precious::Views::Page.new
    @view.instance_variable_set :@page, page
    @view.instance_variable_set :@content, page.formatted_data
    @view.instance_variable_set :@h1_title, false

    # Title is based on file name when h1_title is false.
    actual = @view.title
    assert_equal title, actual
  end
end
