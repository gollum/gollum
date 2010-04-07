require 'helper'

class RepoTest < Test::Unit::TestCase
  def test_repo_creation
    repo = Gollum::Repo.new("examples/lotr")
    assert_equal "examples/lotr", repo.path
  end
end