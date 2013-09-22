require 'spec_helper'

describe Tree do
  
  context "reading trees" do

    before(:each) do
      @bare_repo = Repo.new(TEST_BARE_REPO_PATH, :is_bare => true, :create => false)
      @tree = Tree.find_tree(@bare_repo, 'lib')
    end

    it "should have contents" do
      contents = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, @tree.jtree)
      contents.should be_an Array
      contents.first[:type].should == "blob"
      contents.first[:id].should match /77aa887449c28a922a660b2bb749e4127f7664e5/
      contents[1][:type].should == "tree"
      contents[1][:id].should match /02776a9f673a9cd6e2dfaebdb4a20de867303091/ 
    end
    
    it "has an array of contents" do
      @tree.contents_array.should be_kind_of Array
    end
    
    it "is enumerable" do
      @tree.each {|x| [Blob, Tree].should include(x.class)}
      @tree.map {|x| x.name }.each {|x| x.should be_kind_of String }
    end
    
    it "has trees" do
      @tree.trees.should be_kind_of Array
    end
    
    it "has blobs" do
      @tree.blobs.should be_kind_of Array
    end
    
    it "provides access to its children through the / method" do
      (@tree / "grit.rb").should be_kind_of Blob
      (@tree / "grit").should be_kind_of Tree
      (@tree / "grit/bla").should be_nil
      (@tree / "grit/actor.rb" ).should be_kind_of Blob
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
  
    describe ".find_tree(repository, file_path, branch)" do
      it "should return nil if no tree is found" do
        @tree = Tree.find_tree(@bare_repo, 'abc.argv')
        @tree.should be_nil
      end
    
      it "should return nil if no repository is passed in" do
        @tree = Tree.find_tree(nil, 'lib')
        @tree.should be_nil
      end
    end
  
  end
  
  context "creating trees" do
    before(:all) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end
    
    describe ".new_from_hashmap" do
    
      it "creates a new tree from a hashmap" do
        @tree = Tree.new_from_hashmap(@repo, {"bla" => "bla", "tree" => {"blabla" => "blabla"}})
        @repo.find(@tree.id, :tree).should be_kind_of Tree
        @tree.trees.find {|x| x.name == "tree"}.should be_kind_of Tree
        @tree.blobs.first.name.should == "bla"
      end
      
      it "creates a new tree from a hashmap, based on an old tree" do
        second_tree = Tree.new_from_hashmap(@repo, {"newblob" => "data"}, @repo.head.tree)
        @repo.find(second_tree.id, :tree).should be_kind_of Tree
        second_tree.blobs.length.should be > 1
        second_tree.blobs.find {|x| x.name == "newblob"}.should be_kind_of Blob
      end
    
    end
    
    after(:all) do
      remove_temp_repo(@temp_repo_path)
    end
  end

end
