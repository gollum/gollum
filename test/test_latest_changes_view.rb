# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/latest_changes', __FILE__

context "Precious::Views::LatestChanges" do
  include Rack::Test::Methods
  
  def app
    Precious::App
  end
  
  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {:latest_changes_count => 10})
  end

  test "displays_latest_changes" do
    get('/latest_changes')
    body = last_response.body
    assert body.include?('<span class="username">Charles Pence</span>'), "/latest_changes should include the Author Charles Pence"
    assert body.include?('60f12f4'), "/latest_changes should include the :latest_changes_count commit"
    assert !body.include?('0ed8cbe'), "/latest_changes should not include more than latest_changes_count commits"
    assert body.include?('<a href="Data-Two.csv/874f597a5659b4c3b153674ea04e406ff393975e">Data-Two.csv</a>'), "/latest_changes include links to modified files in #{body}"
    assert body.include?('<a href="Hobbit/874f597a5659b4c3b153674ea04e406ff393975e">Hobbit.md</a>'), "/latest_changes should include links to modified pages in #{body}"
    assert body.include?('<a href="My-Precious/60f12f4254f58801b9ee7db7bca5fa8aeefaa56b">My-&lt;b&gt;Precious.md =&gt; My-Precious.md</a>'), "/latest_changes should indicate renaming action in #{body}"
  end

  test "extract destination file name in case of path renaming" do
    view = Precious::Views::LatestChanges.new
    assert_equal "newDirectoryName/fileName.md", view.extract_renamed_path_destination("{oldDirectoryName => newDirectoryName}/fileName.md")
  end

  test "remove page extentions" do
    view = Precious::Views::LatestChanges.new
    assert_equal "page", view.remove_page_extentions("page.wiki")
    assert_equal "page-wiki", view.remove_page_extentions("page-wiki.md")
    assert_equal "file.any_extention", view.remove_page_extentions("file.any_extention")
  end

  teardown do
    FileUtils.rm_rf(@path)
  end
end
