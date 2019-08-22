# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/latest_changes', __FILE__

context 'Precious::Views::LatestChanges' do
  include Rack::Test::Methods
  
  def app
    Precious::App
  end
  
  setup do
    @path = cloned_testpath('examples/lotr.git')
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {:pagination_count => 10})
  end

  test 'displays_latest_changes' do
    get('/gollum/latest_changes')
    body = last_response.body

    assert body.include?("Charles Pence</span>"), "/latest_changes should include Author Charles Pence"
    assert body.include?('1db89eb'), "/latest_changes should include the :pagination_count commit"
    assert !body.include?('a8ad3c0'), "/latest_changes should not include more than :pagination_count commits"
    assert body.include?('<a href="Data-Two.csv/874f597a5659b4c3b153674ea04e406ff393975e">Data-Two.csv</a>'), "/latest_changes include links to modified files in #{body}"
    assert body.include?('<a href="/Hobbit.md/874f597a5659b4c3b153674ea04e406ff393975e">Hobbit.md</a>'), "/latest_changes should include links to modified pages in #{body}"
  end

  teardown do
    FileUtils.rm_rf(@path)
  end
end

context 'Latest changes with page-file-dir' do
  include Rack::Test::Methods

  def app
    Precious::App
  end

  setup do
    @path = cloned_testpath('examples/lotr.git')
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, { :page_file_dir => 'Rivendell'})
  end

  test 'latest changes respects page_file_dir' do
    get('/gollum/latest_changes')
    body = last_response.body

    assert !body.include?('Hobbit.md'), 'latest changes with page_file_dir should not log changes to files in root'
    assert body.include?('Elrond.md'), 'latest changes should log changes in page_file_dir'
  end

  test 'latest chages should strip off page_file_dir' do
    get('/gollum/latest_changes')
    body = last_response.body
    assert_equal body.include?('<a href="/Rivendell/Elrond.md/'), false
    assert_equal body.include?('<a href="/Elrond.md/'), true
  end

  teardown do
    FileUtils.rm_rf(@path)
    Precious::App.set(:wiki_options, { :page_file_dir => nil})
  end
end
