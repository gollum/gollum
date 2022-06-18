require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context 'Precious::Helpers' do
  include Precious::Helpers
  
  test 'remove trailing and leading slashes' do
    ['/wiki', '/wiki/', 'wiki/', '//wiki//'].each do |param|
      assert_equal 'wiki', remove_leading_and_trailing_slashes(param)
    end
    assert_equal 'wi/ki', remove_leading_and_trailing_slashes('/wi/ki/')
    assert_equal '', remove_leading_and_trailing_slashes('/')
  end
  
  test 'per page upload location helper' do
    # https referer with and without base path
    host_with_port = 'localhost:4567'
    assert_equal 'uploads/Home', find_per_page_upload_subdir('https://localhost:4567/Home.md', host_with_port, nil)
    assert_equal 'uploads/Home', find_per_page_upload_subdir('https://localhost:4567/wiki/Home.md', host_with_port, '/wiki')
    
    # http referer with and without base path
    assert_equal 'uploads/Home', find_per_page_upload_subdir('http://localhost:4567/Home.md', host_with_port,  nil)
    assert_equal 'uploads/Home', find_per_page_upload_subdir('http://localhost:4567/wiki/Home.md', host_with_port, '/wiki')
    
    # edit page referer with and without base path
    assert_equal 'uploads/foo/Home', find_per_page_upload_subdir('http://localhost:4567/gollum/edit/foo/Home.md', host_with_port, nil)
    assert_equal 'uploads/foo/Home', find_per_page_upload_subdir('http://localhost:4567/wiki/gollum/edit/foo/Home.md', host_with_port, '/wiki')
    
    # referer with base path with slashes in the wrong place
    assert_equal 'uploads/Home', find_per_page_upload_subdir('http://localhost:4567/wiki/Home.md', host_with_port, '/wiki/')
    assert_equal 'uploads/Home', find_per_page_upload_subdir('http://localhost:4567/wiki/Home.md', host_with_port, 'wiki')    
  end
end