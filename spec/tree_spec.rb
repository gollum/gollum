require 'spec_helper'

describe Tree do
  
  context "reading trees" do

    before(:each) do
      @bare_repo = Repo.new(TEST_BARE_REPO_PATH, :is_bare => true, :create => false)
      @tree = Tree.find_tree(@bare_repo, 'lib')
    end

    it "has contents" do
      contents = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, @tree.path)
      expect(contents).to be_an Array
      expect(contents.first[:type]).to eq "blob"
      expect(contents.first[:id]).to match /77aa887449c28a922a660b2bb749e4127f7664e5/
      expect(contents[1][:type]).to eq "tree"
      expect(contents[1][:id]).to match /02776a9f673a9cd6e2dfaebdb4a20de867303091/ 
    end
    
    it "has an array of contents" do
      expect(@tree.contents_array).to be_kind_of Array
    end
    
    it "has an array of all contents (recursive)" do
      expect(@tree.recursive_contents_array).to be_kind_of Array
    end
    
    it "has a count" do
      expect(@tree.count).to eq 2
    end
    
    it "has a recursive count" do
      expect(@tree.recursive_count).to eq 20
    end
    
    it "has a recursive count that can be stopped for performance reasons" do
      expect(@tree.recursive_count(limit = 10)).to eq 10
    end
    
    it "is enumerable" do
      @tree.each {|x| expect([Blob, Tree]).to include(x.class)}
      @tree.map {|x| x.name }.each {|x| expect(x).to be_kind_of String }
    end
    
    it "has trees" do
      expect(@tree.trees).to be_kind_of Array
    end
    
    it "has blobs" do
      expect(@tree.blobs).to be_kind_of Array
    end
    
    it "provides access to its children through the / method" do
      expect(@tree / "grit.rb").to be_kind_of Blob
      expect(@tree / "grit").to be_kind_of Tree
      expect(@tree / "grit/bla").to be_nil
      expect(@tree / "grit/actor.rb" ).to be_kind_of Blob
    end

    it "has an id" do
      expect(@tree.id).to match /aa74200714ce8190b38211795f974b4410f5a9d0/
      expect(@tree.get_name).to match /aa74200714ce8190b38211795f974b4410f5a9d0/
    end

    it "has a mode" do
      expect(@tree.mode).to eql TREE_TYPE
    end

    it "returns data as a string" do
      expect(@tree.data).to be_a String
      expect(@tree.data).to match /77aa887449c28a922a660b2bb749e4127f7664e5/ 
    end
  
    describe ".find_tree(repository, file_path, branch)" do
      it "returns nil if no tree is found" do
        @tree = Tree.find_tree(@bare_repo, 'abc.argv')
        expect(@tree).to be_nil
      end
    
      it "returns nil if no repository is passed in" do
        @tree = Tree.find_tree(nil, 'lib')
        expect(@tree).to be_nil
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
        expect(@repo.find(@tree.id, :tree)).to be_kind_of Tree
        expect(@tree.trees.find {|x| x.name == "tree"}).to be_kind_of Tree
        expect(@tree.blobs.first.name).to eq "bla"
      end
      
      it "creates a new tree from a hashmap, based on an old tree" do
        second_tree = Tree.new_from_hashmap(@repo, {"newblob" => "data"}, @repo.head.tree)
        expect(@repo.find(second_tree.id, :tree)).to be_kind_of Tree
        expect(second_tree.blobs.length).to eq 6
        expect(second_tree.blobs.find {|x| x.name == "newblob"}).to be_kind_of Blob
      end
    
    end
    
    after(:all) do
      remove_temp_repo(@temp_repo_path)
    end
  end

end
