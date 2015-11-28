require 'spec_helper'

# Useful command git ls-tree HEAD

describe RJGit do
  before(:all) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH)
    @git = RubyGit.new(@bare_repo.jrepo)
  end
  
  it "has a version" do
    expect(RJGit.version).to eq(RJGit::VERSION)
  end
  
  context "delegating missing methods to the underlying jgit Git object" do
     it "delegates the method to the JGit object" do
       expect(@git.send(:rebase)).to be_a org.eclipse.jgit.api.RebaseCommand # :rebase method not implemented in RubyGit, but is implemented in the underlying JGit object
     end
     
     it "throws an exception if the JGit object does not know the method" do
       expect { @git.send(:non_existent_method) }.to raise_error(NoMethodError)
     end
  end
  
  describe Porcelain do
    before(:all) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      @testfile = 'test_file.txt'
      File.open(File.join(@temp_repo_path, @testfile), 'w') {|file| file.write("This is a new file to add.") }
    end
    
    it "looks up the object belonging to a tag" do
      @repo.git.tag('v0.0', 'initial state commit for a specific commit', @repo.head.jcommit)
      expect(RJGit::Porcelain.object_for_tag(@repo, @repo.tags.first.last)).to be_kind_of Commit
    end
    
    it "mimics git-cat-file" do
      blob = @bare_repo.blob('lib/grit.rb')
      expect(RJGit::Porcelain.cat_file(@bare_repo, blob.jblob)).to match /# core\n/
    end
    
    it "adds files to a repository" do
      Porcelain.add(@repo, @testfile)
      expect(@repo.jrepo.read_dir_cache.find_entry(@testfile).size).to eq 8
    end
    
    it "commits files to a repository" do
      message = "Initial commit"
      Porcelain.commit(@repo, message)
      expect(@repo.commits.last.message.chomp).to eq(message)
    end

      context "listing trees" do
    
        it "mimics git-ls-tree" do
          listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo)
          expect(listing).to be_an Array
          first_entry = listing.first
          expect(first_entry).to be_a Hash
          expect(first_entry[:mode]).to eq REG_FILE_TYPE
          expect(first_entry[:type]).to eq 'blob'
          expect(first_entry[:id]).to match /baaa47163a922b716898936f4ab032db4e08ae8a/
          expect(first_entry[:path]).to eq '.gitignore'
        end
        
        it "mimics git-ls-tree for a specific tree" do
          skip("fails due to bug in ls-tree implementation")
          tree = RJGit::Tree.find_tree(@bare_repo, 'lib')
          listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, tree, {recursive: false})
          first_entry = listing.first
          expect(first_entry[:path]).to eq 'grit.rb'
          tree = RJGit::Tree.find_tree(@bare_repo, 'lib/grit')
          listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, tree, {recursive: false})
          first_entry = listing.first
          expect(first_entry[:path]).to eq 'grit/actor.rb'
        end

        it "mimics git-ls-tree recursively" do
          listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, nil, {recursive: true})
          expect(listing.length).to eq 539
        end

        it "mimics git-ls-tree for a specific path" do
          listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo, nil, {file_path: 'lib'})
          expect(listing.length).to eq 1
        end

      end
    
    it "mimics git-blame" do
      RJGit::Porcelain.blame(@bare_repo, 'lib/grit.rb')
      skip("no expectation defined.")
    end
    
      context "producing diffs" do
        before(:each) do
          @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
          @repo = Repo.new(@temp_repo_path)
          File.open(File.join(@temp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
          @repo.add("rspec-addfile.txt")
        end

        it "returns diffs for a specific path" do
          sha1 = @repo.head.id
          sha2 = @repo.commits.last.id
          options = {old_rev: sha2, new_rev: sha1, file_path: "chapters/prematerial.txt"}
          diff = RJGit::Porcelain.diff(@repo, options).first
          expect(diff[:newpath]).to eq 'chapters/prematerial.txt'
          expect(diff[:changetype]).to eq "ADD"
        end

        it "returns a patch for a diff entry" do
          sha1 = @repo.head.id
          sha2 = @repo.commits.last.id
          options = {old_rev: sha2, new_rev: sha1, file_path: "chapters/prematerial.txt", patch: true}
          diff = RJGit::Porcelain.diff(@repo, options).first
          result = "diff --git a/chapters/prematerial.txt b/chapters/prematerial.txt"
          expect(diff[:patch]).to match /#{result}/
        end

        it "returns a patch for a diff entry with optional formatting"
      
        it "returns cached diff when adding file" do
          entry = RJGit::Porcelain.diff(@repo, {cached: true}).first
          expect(entry).to be_a Hash
          expect(entry[:changetype]).to eq "ADD"
          expect(entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
          @repo.commit("Committing a test file to a test repository.")
          expect(RJGit::Porcelain.diff(@repo)).to eq []
        end
      
        it "returns cached diff when removing file" do 
          @repo.commit("Adding rspec-addfile.txt so it can be deleted.")
          @repo.remove("rspec-addfile.txt")
          entry = RJGit::Porcelain.diff(@repo, {cached: true}).first
          expect(entry[:changetype]).to eq "DELETE"
          expect(entry[:oldpath]).to eq "rspec-addfile.txt"
          @repo.commit("Removing test file.")
          expect(RJGit::Porcelain.diff(@repo)).to eq []
        end
      
        after(:each) do
          @repo = nil
	        remove_temp_repo(@temp_repo_path)
        end 
      end
    
    after(:all) do
      @repo = nil
      remove_temp_repo(@temp_repo_path)
    end
    
  end # end Porcelain
  
  describe Plumbing do
    
    describe RJGit::Plumbing::Index do
      before(:all) do
        @temp_repo_path = get_new_temp_repo_path(true)
        @repo = Repo.new(@temp_repo_path, create: true, is_bare: true)
        @index = RJGit::Plumbing::Index.new(@repo)
        @msg = "Message"
        @auth = RJGit::Actor.new("test", "test@repotag.org")
      end
      
      it "has a treemap" do
        expect(@index.treemap).to be_kind_of Hash
      end
      
      it "adds blobs to the treemap" do
        @index.add("test", "Test")
        expect(@index.treemap["test"]). to eq "Test"
      end
      
      it "adds trees to the treemap" do
        @index.add("tree/blob", "Test")
        expect(@index.treemap["tree"]).to eq({"blob" => "Test"})
      end
      
      it "adds items to delete to the treemap" do
        @index.delete("tree/blob")
        expect(@index.treemap["tree"]["blob"]).to be false
      end
      
      it "adds commits to an empty repository" do
        res, log = @index.commit(@msg, @auth)
        expect(res).to eq "NEW"
        expect(@repo.blob("test").data).to eq "Test"
        expect(@repo.commits.first.parents).to be_empty
      end
      
      it "adds commits with a parent commit" do
        @index.add("tree/blob", "Test")
        res, log = @index.commit(@msg, @auth)
        expect(res).to eq "FAST_FORWARD"
        expect(@repo.blob("tree/blob").data).to eq "Test"
        expect(@repo.commits.first.parents).to_not be_empty
      end
      
      it "returns log information after commit" do
        @index.add("tree/blob2", "Tester")
        res, log = @index.commit(@msg, @auth)
        expect(log[:added].select {|x| x.include?("tree")}.first).to include(:tree)
      end
      
      it "commits to a non-default branch" do
        msg = "Branch test"
        @index.add("tree/blob3", "More testing")
        res, log = @index.commit(msg, @auth, nil, "refs/heads/newbranch")
        expect(@repo.commits("newbranch").first.message).to eq msg
      end
      
      it "allows setting multiple parents for a commit" do
        @index.delete("tree/blob2")
        parents = [@repo.commits.first, @repo.commits.last]
        res, log = @index.commit(@msg, @auth, parents)
        expect(@repo.commits.first.parents.length).to eq 2
      end
      
      it "allows setting the departure tree when building a new commit" do
        @index.add("newtree/blobinnewtree", "contents")
        res, log = @index.commit(@msg, @auth)
        tree = @repo.tree("newtree").jtree
        @index.current_tree = tree
        @index.add("secondblob", "other contents")
        res, log = @index.commit(@msg, @auth)
        expect(@repo.blob("blobinnewtree").data).to eq "contents"
        expect(@repo.blob("secondblob").data).to eq "other contents"
        @index.current_tree = nil
      end
      
      it "tells whether a response code indicates a successful response" do
        ["NEW", "FAST_FORWARD"].each do |s|
          expect(RJGit::Plumbing::Index.successful?(s)).to be true
        end
        expect(RJGit::Plumbing::Index.successful?("FAILED")).to be false
      end
      
      after(:all) do
        remove_temp_repo(@temp_repo_path)
        @repo = nil
      end
    
    end
    
    describe RJGit::Plumbing::TreeBuilder do
      before(:all) do
        @temp_repo_path = get_new_temp_repo_path(true)
        @repo = Repo.new(@temp_repo_path, create: true, is_bare: true)
        @msg = "Message"
        @auth = RJGit::Actor.new("test", "test@repotag.org")
        @index = RJGit::Plumbing::Index.new(@repo)
        @index.add('bla', 'test')
        @index.commit(@msg, @auth)
        @tb = RJGit::Plumbing::TreeBuilder.new(@repo)
      end
      
      it "initializes with the right defaults" do
        expect(@tb.object_inserter).to be_kind_of org.eclipse.jgit.lib.ObjectInserter
        expect(@tb.treemap).to eq({})
        expect(@tb.log).to eq({deleted: [], added: [] })
      end
      
      it "adds and deletes objects to a tree" do
        @tb.treemap = {"newtest/bla" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        expect(tree).to be_kind_of org.eclipse.jgit.lib.ObjectId
        
        treewalk = TreeWalk.new(@repo.jrepo)
        treewalk.add_tree(tree)
        treewalk.set_recursive(true)
        objects = []
        while treewalk.next
          objects << treewalk.get_path_string
        end
        expect(objects).to include("newtest/bla")
        
        @index.add('newtest/bla', 'contents')
        @index.commit(@msg, @auth)
        
        @tb.treemap = {"newtest" => false}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        
        treewalk = TreeWalk.new(@repo.jrepo)
        treewalk.add_tree(tree)
        treewalk.set_recursive(true)
        objects = []
        while treewalk.next
          objects << treewalk.get_path_string
        end
        expect(objects).to_not include("newtest/bla")
      end
      
      it "logs information about added and deleted objects" do
        @tb.init_log
        @tb.treemap = {"newtest" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        expect(@tb.log[:added].first).to include(:blob)
        expect(@tb.log[:deleted]).to be_empty
        @tb.treemap = {"newtest" => false}
        @tb.build_tree(tree)
        expect(@tb.log[:deleted].first).to include(:blob)
        expect(@tb.log[:deleted].first).to include("newtest")
      end
      
      it "does not log information about trees that contain no added objects" do
        @tb.treemap = {"newtree/test/newblob" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        @tb.init_log
        @tb.treemap = {"newtree/test/newblob" => false}
        @tb.build_tree(tree)
        expect(@tb.log[:added]).to be_empty
      end
      
      it "tells whether a given hashmap contains no added blobs" do
        expect(@tb.only_contains_deletions({'test' => {'test' => false}})).to be true
        expect(@tb.only_contains_deletions({'test' => {'test' => false, 'test2' => 'content'}})).to be false
      end
      
      after(:all) do
        remove_temp_repo(@temp_repo_path)
        @repo = nil
      end
      
    end
    
  end
  
  describe "helper methods" do
    specify {expect(RJGit.blob_type("A String")).to be_nil}
    specify {expect(RJGit.repository_type("A String")).to be_nil}
    specify {expect(RJGit.tree_type("A String")).to be_nil}
    specify {expect(RJGit.actor_type("A String")).to be_nil}
    specify {expect(RJGit.commit_type("A String")).to be_nil}
    specify {expect(RJGit.underscore("CamelCaseToSnakeCase")).to eq 'camel_case_to_snake_case'}
    specify {{Constants::OBJ_BLOB => :blob, Constants::OBJ_COMMIT => :commit, Constants::OBJ_TREE => :tree, Constants::OBJ_TAG => :tag }.each {|k,v| expect(RJGit.sym_for_type(k)).to eq v}}
  end
  
  after(:all) do
    @bare_repo = nil
  end
end