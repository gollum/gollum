require 'spec_helper'

describe Commit do
  
  context "creating commits" do
    before(:all) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end
    
      describe "is created from a tree and commit info" do
    
        it "writes a new commit to the repository based on a tree" do
          commit = Commit.new_with_tree(@repo, @repo.head.tree, "creation test", @repo.head.actor, @repo.head)
          expect(commit.parent_count).to eq 1
          expect(@repo.find(commit.id, :commit).id).to eq commit.id
        end
    
        it "creates commits with no parents" do
          commit = Commit.new_with_tree(@repo, @repo.head.tree, "creation test", @repo.commits.first.actor, [])
          expect(commit.parent_count).to eq 0
        end
    
      end
    
    after(:all) do
      remove_temp_repo(@temp_repo_path)
    end
  end
  
  context "reading commits" do

    before(:each) do
      @bare_repo = Repo.new(TEST_BARE_REPO_PATH, :is_bare => true, :create => false)
      @commit = @bare_repo.commits.first
    end

    after(:each) do
      @bare_repo = nil
    end

    it "has an id" do
      expect(@commit.id).to match /ca8a30f5a7f0f163bbe3b6f0abf18a6c83b0687a/
      expect(@commit.get_name).to match /ca8a30f5a7f0f163bbe3b6f0abf18a6c83b0687a/
    end
  
    it "points to a tree" do
      expect(@commit.tree).to be_an RJGit::Tree
    end

    it "has an associated actor" do
      actor = @commit.actor
      expect(actor.name).to eq 'Scott Chacon'
      expect(actor.email).to eq 'schacon@gmail.com'
    end
  
    it "has a committer" do
      expect(@commit.committer.name).to eq 'Scott Chacon'
    end

    it "has parent commits" do
      expect(@commit.parents).to be_an Array
      expect(@commit.parents.first.id).to match /3fa4e130fa18c92e3030d4accb5d3e0cadd40157/
      head = @bare_repo.head
      expect(head.parents).to be_an Array
      expect(head.parents.first.id).to match /3fa4e130fa18c92e3030d4accb5d3e0cadd40157/
    end
  
    it "has a message" do
      expect(@commit.message).to match /added a pure-ruby git library and converted the cat_file commands to use it/
    end
  
    it "has a short message" do
      expect(@commit.short_message).to match /pure-ruby git library/
    end

    it "has a count" do
      expect(@commit.parent_count).to eq 1
    end

    it "has stats" do
      stats = Repo.new(TEST_REPO_PATH).commits[-2].stats
      expect(stats[0]).to eq 8
      expect(stats[1]).to eq 2
      expect(stats[2]["postpatriarchialist.txt"]).to eq([2, 0, 2])
    end

    it "has stats on first commit" do
      stats = Repo.new(TEST_REPO_PATH).commits[-1].stats
      expect(stats[0]).to eq 228
      expect(stats[1]).to eq 0
      expect(stats[2]["postpatriarchialist.txt"]).to eq([75, 0, 75])
    end
    
    it "has diffs compared with parent commit" do
      diffs = @commit.diffs
      expect(diffs.size).to eq 14
      expect(diffs[1]).to match /index 6afcf64..77aa887 100644/
    end
    
    it "has one diff string" do
      expect(@commit.diff.size).to eq 39074
    end

    describe ".find_all(repo, ref, options)" do
      it "returns an empty array if nothing is found" do
        @commits = Commit.find_all(@bare_repo, 'remote42', {:limit => 10 })
        expect(@commits).to be_an Array
        expect(@commits).to be_empty
      end
    
      it "returns nil if something other than a repository is passed in" do
        expect(Commit.find_all('A String Object', 'remote42', {:limit => 10 })).to be_nil
      end
    
    end
  
    describe ".find_head(repository)" do
      it "returns a single RJGit::Commit object" do
        @commit = Commit.find_head(@bare_repo)
        expect(@commit).to be_a RJGit::Commit
      end
    
      it "returns nil if no head can be found" do
        @commit = Commit.find_head(Repo.new(get_new_temp_repo_path))
        expect(@commit).to be_nil
      end
    end
  
  end

end
