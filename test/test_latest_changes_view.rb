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
    Precious::App.set(:wiki_options, {})
  end

  test "displays_latest_changes" do
    get('/latest_changes')
    body = last_response.body
    assert body.include?('<span class="username">Charles Pence</span>'), "/latest_changes should include the Author Charles Pence"
    assert body.include?('4c45c2b'), "/latest_changes should include commit #4c45c2b"
    assert !body.include?('4c45c2g'), "latest_changes should not include commit #4c45c2g"
    assert body.include?('<a href="Hobbit/874f597a5659b4c3b153674ea04e406ff393975e">Hobbit</a>'), "/latest_changes should include links to modified pages"
  end
  
  teardown do
    FileUtils.rm_rf(@path)
  end
end
