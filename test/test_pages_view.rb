# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/pages', __FILE__

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

context "Precious::Views::Pages" do
  setup do
    @page = Precious::Views::Pages.new
  end

  test "breadcrumb" do
    @page.instance_variable_set("@path", "Mordor/Eye-Of-Sauron/Saruman")
    @page.instance_variable_set("@base_url", "")
    assert_equal '<a href="/gollum/pages">Home</a> / <a href="/gollum/pages/Mordor/">Mordor</a> / <a href="/gollum/pages/Mordor/Eye-Of-Sauron/">Eye-Of-Sauron</a> / Saruman', @page.breadcrumb
  end

  test "breadcrumb with no path" do
    assert_equal 'Home', @page.breadcrumb
  end

  test "folders first" do
    @page.instance_variable_set("@base_url", "")
	results = [FakePageResult.new("Gondor/Bromir.md"), FakePageResult.new("Hobbit.md"), FakePageResult.new("Home.md"), FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakePageResult.new("Mordor/todo.md"), FakePageResult.new("Rivendell/Elrond.md"), FakePageResult.new("My-Precious.md"), FakePageResult.new("Zamin.md"), FakePageResult.new("Samwise-Gamgee.md"), FakePageResult.new("roast-mutton.md"), FakePageResult.new("Bilbo-Baggins.md")]
    @page.instance_variable_set("@results", results)
    assert_equal %{<li><a href="/gollum/pages/Gondor/" class="folder">Gondor</a></li>\n<li><a href="/gollum/pages/Mordor/" class="folder">Mordor</a></li>\n<li><a href="/gollum/pages/Rivendell/" class="folder">Rivendell</a></li>\n<li><a href="/Bilbo-Baggins" class="page">Bilbo Baggins</a></li>\n<li><a href="/Hobbit" class="page">Hobbit</a></li>\n<li><a href="/Home" class="page">Home</a></li>\n<li><a href="/My-Precious" class="page">My Precious</a></li>\n<li><a href="/roast-mutton" class="page">roast mutton</a></li>\n<li><a href="/Samwise-Gamgee" class="page">Samwise Gamgee</a></li>\n<li><a href="/Zamin" class="page">Zamin</a></li>}, @page.files_folders
  end

  test "files_folders from subdir" do
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "")
    results = [FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakeFileResult.new("Mordor/Aragorn.pdf"), FakePageResult.new("Mordor/Orc/Saruman.md"), FakeFileResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    assert_equal %{<li><a href="/gollum/pages/Mordor/Orc/" class="folder">Orc</a></li>\n<li><a href="/Mordor/Aragorn.pdf" class="file">Aragorn.pdf</a></li>\n<li><a href="/Mordor/Eye-Of-Sauron" class="page">Eye Of Sauron</a></li>}, @page.files_folders
  end

  test "base url" do
    # based on test "files_folders"
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "/wiki")
    results = [FakePageResult.new("Mordor/Eye-Of-Sauron.md"), FakeFileResult.new("Mordor/Aragorn.pdf"), FakePageResult.new("Mordor/Orc/Saruman.md"), FakePageResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    assert_equal %{<li><a href="/wiki/gollum/pages/Mordor/Orc/" class="folder">Orc</a></li>\n<li><a href="/wiki/Mordor/Aragorn.pdf" class="file">Aragorn.pdf</a></li>\n<li><a href="/wiki/Mordor/Eye-Of-Sauron" class="page">Eye Of Sauron</a></li>}, @page.files_folders
  end
end
