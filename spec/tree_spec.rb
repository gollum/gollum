require 'spec_helper'

describe Tree do

  before(:each) do
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @bare_repo = Repo.new(@temp_bare_repo_path, {:bare => true}, false)
    @tree = Tree.find_tree(@bare_repo.repo, 'lib')
    #@tree = repo.commits.first.tree
  end

  it "should have contents" do
    contents = RJGit::Porcelain.ls_tree(@bare_repo.repo, @tree.revtree)
    contents.should be_an Array
    contents.first[:type].should == "blob"
    contents.first[:id].should match /77aa887449c28a922a660b2bb749e4127f7664e5/
    contents[1][:type].should == "tree"
    contents[1][:id].should match /02776a9f673a9cd6e2dfaebdb4a20de867303091/ 
  end

  it "should have an id" do
    @tree.id.should match /aa74200714ce8190b38211795f974b4410f5a9d0/
  end

  it "should have a mode" do
    @tree.mode.should eql TREE_TYPE
  end

  it "should return data as a string" do
    @tree.data.should be_a String
    @tree.data.should match /77aa887449c28a922a660b2bb749e4127f7664e5/ 
  end

end
