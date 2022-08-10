# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/overview', __FILE__

FakePageResult = Struct.new(:path) do
  def name
    File.basename(path, File.extname(path)).gsub("-", " ")
  end
  alias filename name
  def escaped_url_path
    CGI.escape(path).gsub(/\..+$/, "").gsub("%2F", "/")
  end
  def url_path
    path
  end
  def format
    true
  end
end

FakeFileResult = Struct.new(:path) do
  def name
    File.basename(path).gsub("-", " ")
  end
  alias filename name
  def url_path
    path
  end
  def escaped_url_path
    result = path.sub(/\/[^\/]+$/, '/')
    result = result << name if result.include?('/')
    CGI.escape(result).gsub("%2F", "/")
  end  
end

context "Precious::Views::Overview" do
  setup do
    @page = Precious::Views::Overview.new
  end

  test "breadcrumb" do
    @page.instance_variable_set("@path", "Mordor/Eye-Of-Sauron/Saruman")
    @page.instance_variable_set("@base_url", "")
    assert_equal "<nav aria-label=\"Breadcrumb\"><ol><li class=\"breadcrumb-item\"><a href=\"/gollum/overview\">Home</a></li>\n<li class=\"breadcrumb-item\"><a href=\"/gollum/overview/Mordor/\">Mordor</a></li>\n<li class=\"breadcrumb-item\"><a href=\"/gollum/overview/Mordor/Eye-Of-Sauron/\">Eye-Of-Sauron</a></li>\n<li class=\"breadcrumb-item\" aria-current=\"page\">Saruman</li>\n</ol></nav>", @page.breadcrumb
  end

  test "breadcrumbs guard against malicious filenames" do
    malicious_path = '<script>alert("malicious-content");/Very Bad'
    @page.instance_variable_set("@path", malicious_path)
    @page.instance_variable_set("@base_url", "")

    refute_includes @page.breadcrumb, malicious_path
    assert_includes @page.breadcrumb, ">&lt;script&gt;alert(&quot;malicious-content&quot;);</a>"
  end

  test "breadcrumbs retain unicode and ASCII characters" do
    title = "数学 📘"
    @page.instance_variable_set("@path", title)
    @page.instance_variable_set("@base_url", "")

    assert_includes @page.breadcrumb, title
  end

  test "breadcrumb with no path" do
    assert_equal 'Home', @page.breadcrumb
  end

  test "folders first" do
    @page.instance_variable_set("@base_url", "")
	results = [FakePageResult.new("Gondor/Boromir.md"), FakePageResult.new("Hobbit.md"), FakePageResult.new("Home.md"), FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakePageResult.new("Mordor/todo.md"), FakePageResult.new("Rivendell/Elrond.md"), FakePageResult.new("My-Precious.md"), FakePageResult.new("Zamin.md"), FakePageResult.new("Samwise-Gamgee.md"), FakePageResult.new("roast-mutton.md"), FakePageResult.new("Bilbo-Baggins.md")]
    @page.instance_variable_set("@results", results)
    files = 0
    folders = 0
    results = @page.files_folders
    results[0..2].each { |r| assert r[:type] == 'dir' }
    results[3..-1].each { |r| assert r[:type] == 'file' }
  end

  test "files_folders from subdir" do
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "")
    results = [FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakeFileResult.new("Mordor/Aragorn.pdf"), FakePageResult.new("Mordor/Orc/Saruman.md"), FakeFileResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    result = @page.files_folders.first
    assert_equal result[:icon].start_with?('<svg class="octicon octicon-file-directory'), true
    assert_equal result[:type], 'dir'
    assert_equal result[:url], '/gollum/overview/Mordor/Orc/'
    assert_equal result[:is_file], false
    assert_equal result[:name], 'Orc'
  end

  test "files_folders retain unicode and ASCII characters" do
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "")
    @page.instance_variable_set("@results", [
      FakePageResult.new("Mordor/Eye-Of-Sauron-👁️-数学.md")
    ])
    result = @page.files_folders.first

    assert result[:name], "Eye Of Sauron 👁️ 数学"
  end

  test "base url" do
    # based on test "files_folders"
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "/wiki")
    results = [FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakeFileResult.new("Mordor/Aragorn.pdf"), FakePageResult.new("Mordor/Orc/Saruman.md"), FakePageResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    assert_equal @page.files_folders.first[:url], '/wiki/gollum/overview/Mordor/Orc/'
    assert_equal @page.files_folders.last[:url], '/wiki/Mordor/Eye-Of-Sauron'
    assert_equal @page.files_folders.last[:file_path], 'Mordor/Eye-Of-Sauron'
  end
end
