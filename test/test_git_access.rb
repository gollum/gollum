require File.join(File.dirname(__FILE__), *%w[helper])

context "GitAccess" do
  setup do
    @access = Gollum::GitAccess.new(testpath("examples/lotr.git"))
  end

  test "#commit fills commit_map cache" do
    assert @access.commit_map.empty?
    actual   = @access.repo.commits.first
    expected = @access.commit(actual.id)
    assert_equal actual.message, expected.message
    assert_equal actual.message, @access.commit_map[actual.id].message
  end

  test "#commits uses commit_map" do
    actual = @access.repo.commits.first
    #@access.commit actual.id
    @access.commit_map['abc'] = 1
    commits = @access.commits('abc', actual.id)
    assert_equal 1, commits[0]
    assert_equal actual.message, commits[1].message
  end

  test "#tree_map_for caches ref and tree" do
    assert @access.ref_map.empty?
    assert @access.tree_map.empty?
    @access.tree 'master'
    assert_equal({"master"=>"60f12f4254f58801b9ee7db7bca5fa8aeefaa56b"}, @access.ref_map)
  
    map = @access.tree_map['60f12f4254f58801b9ee7db7bca5fa8aeefaa56b']
    assert_equal 'Bilbo-Baggins.md',        map[0].path
    assert_equal '',                        map[0].dir
    assert_equal map[0].path,               map[0].name
    assert_equal 'Mordor/Eye-Of-Sauron.md', map[3].path
    assert_equal '/Mordor',                 map[3].dir
    assert_equal 'Eye-Of-Sauron.md',        map[3].name
  end

  test "#tree_map_for only caches tree for commit" do
    assert @access.tree_map.empty?
    @access.tree '60f12f4254f58801b9ee7db7bca5fa8aeefaa56b'
    assert @access.ref_map.empty?

    entry = @access.tree_map['60f12f4254f58801b9ee7db7bca5fa8aeefaa56b'][0]
    assert_equal 'Bilbo-Baggins.md', entry.path
  end
end