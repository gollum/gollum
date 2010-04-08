require File.join(File.dirname(__FILE__), *%w[helper])

context "Wiki" do
  setup do
    @repo = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "repo path" do
    assert_equal testpath("examples/lotr.git"), @repo.path
  end

  test "git repo" do
    assert_equal Grit::Repo, @repo.repo.class
  end
end