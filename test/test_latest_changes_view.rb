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
    @url = '/gollum/latest_changes'
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {:pagination_count => 10})
  end

  test "displays_latest_changes" do
    get(@url)
    body = last_response.body

    assert body.include?("Charles Pence</span>"), "/latest_changes should include Author Charles Pence"
    assert body.include?('1db89eb'), "/latest_changes should include the :pagination_count commit"
    assert !body.include?('a8ad3c0'), "/latest_changes should not include more than :pagination_count commits"
    assert body.include?('<a href="Data-Two.csv/874f597a5659b4c3b153674ea04e406ff393975e">Data-Two.csv</a>'), "/latest_changes include links to modified files in #{body}"
    assert body.include?('<a href="Hobbit.md/874f597a5659b4c3b153674ea04e406ff393975e">Hobbit.md</a>'), "/latest_changes should include links to modified pages in #{body}"
  end

  test 'gravatar' do
    Precious::App.set(:wiki_options, {:user_icons => 'gravatar'})
    get @url
    assert last_response.body.include?('<img src="https://secure.gravatar.com/'), "gravatar icon missing from #{@url}"
    Precious::App.set(:wiki_options, {:user_icons => 'none'})
  end
  
  test 'identicon' do
    Precious::App.set(:wiki_options, {:user_icons => 'identicon'})
    get @url
    assert last_response.body.include?('class="identicon" data-identicon="'), "identicon icon missing from #{@url}"
    Precious::App.set(:wiki_options, {:user_icons => 'none'})
  end

  test "extract destination file name in case of path renaming" do
    view = Precious::Views::LatestChanges.new
    assert_equal "newname.md", view.extract_renamed_path_destination("oldname.md => newname.md")
    assert_equal "newDirectoryName/fileName.md", view.extract_renamed_path_destination("{oldDirectoryName => newDirectoryName}/fileName.md")
  end

  teardown do
    FileUtils.rm_rf(@path)
  end
end