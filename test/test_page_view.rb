# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/page', __FILE__

context "Precious::Views::Page" do
  setup do
    @path = testpath("examples/test.git")
    FileUtils.rm_rf(@path)
    @repo = Grit::Repo.init_bare(@path)
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
    assert_equal 'H1', title
  end
end