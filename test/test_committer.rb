require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Wiki" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "normalizes commit hash" do
    commit = {:message => 'abc'}
    name  = @wiki.repo.config['user.name']
    email = @wiki.repo.config['user.email']
    committer = Gollum::Committer.new(@wiki, commit)
    assert_equal name,  committer.actor.name
    assert_equal email, committer.actor.email

    commit[:name]  = 'bob'
    commit[:email] = ''
    committer = Gollum::Committer.new(@wiki, commit)
    assert_equal 'bob',  committer.actor.name
    assert_equal email, committer.actor.email

    commit[:email] = 'foo@bar.com'
    committer = Gollum::Committer.new(@wiki, commit)
    assert_equal 'bob',  committer.actor.name
    assert_equal 'foo@bar.com', committer.actor.email
  end
end