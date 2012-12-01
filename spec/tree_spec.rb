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

  describe "content_from String" do
    it "should return a tree" do
      pending
      # text = fixture('ls_tree_a').split("\n").last
      # tree = @tree.content_from_string(nil, text)
      # tree.class.should eql Tree
      # tree.id.should == "650fa3f0c17f1edb4ae53d8dcca4ac59d86e6c44"
      # tree.mode.should == "040000"
      # tree.name.should == "test"
    end

    it "should return a blob" do
      pending
      # text = fixture('ls_tree_b').split("\n").first
      # tree = @tree.content_from_string(nil, text)
      # tree.class.should eql Blob
      # tree.id.should == "aa94e396335d2957ca92606f909e53e7beaf3fbb"
      # tree.mode.should == "100644"
      # tree.name.should == "grit.rb"
    end

  end

end
