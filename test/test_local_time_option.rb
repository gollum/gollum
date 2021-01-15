# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require 'nokogiri'
require 'json'
require 'time'

def local_time
  Precious::App.set(:wiki_options, { show_local_time: true})
end

def no_local_time
  Precious::App.set(:wiki_options, { show_local_time: false})
end

def assert_time_tags(body)
  tags = Nokogiri::HTML(body).css('time')
  assert_equal tags.empty?, false
  tags.each do |tag|
    assert Time.parse(tag[:datetime]).utc?
  end
end

context ":show_local_time option" do
  include Rack::Test::Methods
  
  setup do
    @path = cloned_testpath('examples/lotr.git')
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    local_time()
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

  test "last_commit_info no local time" do
    no_local_time()
    get '/gollum/last_commit_info', {path: 'Home.textile'}
    assert_equal Time.parse(JSON.parse(last_response.body)['date']).utc?, false
  end
  
  test "last_commit_info local time" do
    local_time()
    get '/gollum/last_commit_info', {path: 'Home.textile'}
    assert Time.parse(JSON.parse(last_response.body)['date']).utc?
  end
  
  test "datetime attributes in utc" do
    get '/Home/b0d108328459e44fff4a76cd19b10ddc34adce4b'
    assert_time_tags last_response.body
    
    get '/gollum/latest_changes'
    assert_time_tags last_response.body
    
    get '/gollum/history/Home'
    assert_time_tags last_response.body
    
    get '/gollum/commit/b0d108328459e44fff4a76cd19b10ddc34adce4b'
    assert_time_tags last_response.body
  end

  def app
    Precious::App
  end
end
