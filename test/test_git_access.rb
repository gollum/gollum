# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

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

  test "#tree_map_for caches ref and tree" do
    assert @access.ref_map.empty?
    assert @access.tree_map.empty?
    @access.tree 'master'
    assert_equal({"master"=>"b0de6e794dfdc7ef3400e894225bfe23308aae5c"}, @access.ref_map)

    @access.tree '1db89ebba7e2c14d93b94ff98cfa3708a4f0d4e3'
    map = @access.tree_map['1db89ebba7e2c14d93b94ff98cfa3708a4f0d4e3']
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

  test "cannot access commit from invalid ref" do
    assert_nil @access.commit('foo')
  end

  test "cannot access sha from invalid ref" do
    assert_nil @access.ref_to_sha('foo')
  end

  test "cannot access tree from invalid ref" do
    assert_equal [], @access.tree('foo')
  end
end
