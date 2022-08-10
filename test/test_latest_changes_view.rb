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
    @url = '/gollum/latest_changes'
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {:pagination_count => 10})
  end

  test 'rename detection' do
    versions = [OpenStruct.new(
        :id     => 'fake',
        :author => OpenStruct.new(:email => 'fake', :name => 'fake'),
        :message => 'fake',
        :authored_date => Time.now,
        :stats => OpenStruct.new(:files => [{:new_file => 'new_path', :old_file => 'old_path', :new_additions => 1, :new_deletions => 1, :changes => 1}])
      )]
    view = Precious::Views::LatestChanges.new
    view.instance_variable_set(:@versions, versions)
    view.instance_variable_set(:@request, OpenStruct.new(:host => 'fake')) # dummy to generate gravatar icon
    assert_equal view.versions[0][:files][0][:renamed], 'old_path'
  end

  test "displays_latest_changes" do
    get(@url)
    body = last_response.body

    commits_list_elements = body.scan(%r{<li class="Box-row Box-row--hover-gray border-top d-flex flex-items-center">})
    assert !commits_list_elements.nil?, "the commits should be listed with this tag"
    assert commits_list_elements.length == 10, "/latest_changes should include the :pagination_count commit"

    assert body.include?("Charles Pence</span>"), "/latest_changes should include Author Charles Pence"
    assert body.include?('<a href="/Data-Two.csv/874f597a5659b4c3b153674ea04e406ff393975e">Data-Two.csv</a>'), "/latest_changes include links to modified files in #{body}"
    assert body.include?('<a href="/Hobbit.md/874f597a5659b4c3b153674ea04e406ff393975e">Hobbit.md</a>'), "/latest_changes should include links to modified pages in #{body}"
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

  test 'latest changes should strip off page_file_dir' do
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
