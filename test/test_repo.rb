require 'helper'

context "Repo" do
  setup do
    @repo = Gollum::Repo.new("examples/lotr.git")
  end

  test "repo path" do
    assert_equal "examples/lotr.git", @repo.path
  end

  test "git repo" do
    assert_equal Grit::Repo, @repo.repo.class
  end
end