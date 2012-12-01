require 'spec_helper'

describe Tree do

  before(:each) do
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @bare_repo = Repo.new(@temp_bare_repo_path, {:bare => true}, false)
    @tree = Tree.find_tree(@bare_repo.repo, 'lib')
    #@tree = repo.commits.first.tree
  end

  it "should have contents"

  it "should have an id" do
    @tree.id.should match /aa74200714ce8190b38211795f974b4410f5a9d0/
  end

  it "should have a mode" do
    @tree.mode.should eql TREE_TYPE
  end

  it "should return data as a string"

end
