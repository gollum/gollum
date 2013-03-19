# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/pages', __FILE__

FakeResult = Struct.new(:path) do
  def name
    File.basename(path, File.extname(path)).gsub("-", " ")
  end

  def escaped_url_path
    CGI.escape(path).gsub(/\..+$/, "").gsub("%2F", "/")
  end
end

context "Precious::Views::Pages" do
  setup do
    @page = Precious::Views::Pages.new
  end

  test "breadcrumb" do
    @page.instance_variable_set("@path", "Mordor/Eye-Of-Sauron/Saruman")
    @page.instance_variable_set("@base_url", "")
    assert_equal '<a href="/pages/">Home</a> / <a href="/pages/Mordor/">Mordor</a> / <a href="/pages/Mordor/Eye-Of-Sauron/">Eye-Of-Sauron</a> / Saruman', @page.breadcrumb
  end

  test "breadcrumb with no path" do
    assert_equal 'Home', @page.breadcrumb
  end

  test "files_folders" do
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "")
    results = [FakeResult.new("Mordor/Eye-Of-Sauron.md"), FakeResult.new("Mordor/Orc/Saruman.md"), FakeResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    assert_equal %{<li><a href="/Mordor/Eye-Of-Sauron" class="file">Eye Of Sauron</a></li>\n<li><a href="/pages/Mordor/Orc/" class="folder">Orc</a></li>}, @page.files_folders
  end

  test "base url" do
    # based on test "files_folders"
    @page.instance_variable_set("@path", "Mordor")
    @page.instance_variable_set("@base_url", "/wiki")
    results = [FakeResult.new("Mordor/Eye-Of-Sauron.md"), FakeResult.new("Mordor/Orc/Saruman.md"), FakeResult.new("Mordor/.gitkeep")]
    @page.instance_variable_set("@results", results)
    assert_equal %{<li><a href="/wiki/Mordor/Eye-Of-Sauron" class="file">Eye Of Sauron</a></li>\n<li><a href="/wiki/pages/Mordor/Orc/" class="folder">Orc</a></li>}, @page.files_folders
  end
end
