require 'spec_helper'

# Useful command git ls-tree HEAD

describe RJGit do
  before(:all) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH)
    @git = RubyGit.new(@bare_repo.jrepo)
  end
  
  it "should have a version" do
    RJGit.version.should equal RJGit::VERSION
  end
  
  context "delegating missing methods to the underlying jgit Git object" do
     it "should delegate the method to the JGit object" do
       @git.send(:rebase).should be_a org.eclipse.jgit.api.RebaseCommand # :rebase method not implemented in RubyGit, but is implemented in the underlying JGit object
     end
     
     it "should throw an exception if the JGit object does not know the method" do
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
    
    it "should mimic git-cat-file" do
      blob = @bare_repo.blob('lib/grit.rb')
      RJGit::Porcelain.cat_file(@bare_repo, blob.jblob).should =~ /# core\n/
    end
    
    it "should add files to a repository" do
      Porcelain.add(@repo, @testfile)
      @repo.jrepo.read_dir_cache.find_entry(@testfile).should have_at_least(1).entries
    end
    
    it "should commit files to a repository" do
      message = "Initial commit"
      Porcelain.commit(@repo, message)
      @repo.commits.last.message.chomp.should == message
    end
    
    it "should mimic git-ls-tree" do
      listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo)
      listing.should be_an Array
      first_entry = listing.first
      first_entry.should be_a Hash
      first_entry[:mode].should == REG_FILE_TYPE
      first_entry[:type].should == 'blob'
      first_entry[:id].should match /baaa47163a922b716898936f4ab032db4e08ae8a/
      first_entry[:path].should == '.gitignore'
    end
    
    it "should mimic git-blame" do
      RJGit::Porcelain.blame(@bare_repo, 'lib/grit.rb')
    end
    
      context "producing diffs" do
        before(:each) do
          @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
          @repo = Repo.new(@temp_repo_path)
          File.open(File.join(@temp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
          @repo.add("rspec-addfile.txt")
        end
      
        it "should return diff information of working tree when adding file" do
          entry = RJGit::Porcelain.diff(@repo, {:cached => true}).first
          entry.should be_a Hash
          entry[:changetype].should == "ADD"
          entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
          @repo.commit("Committing a test file to a test repository.")
          RJGit::Porcelain.diff(@repo).should == []
        end
      
        it "should return diff information of working tree when removing file" do 
          @repo.commit("Adding rspec-addfile.txt so it can be deleted.")
          @repo.remove("rspec-addfile.txt")
          entry = RJGit::Porcelain.diff(@repo, {:cached => true}).first
          entry[:changetype].should == "DELETE"
          entry[:oldpath].should == "rspec-addfile.txt"
          @repo.commit("Removing test file.")
          RJGit::Porcelain.diff(@repo).should == []
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
        @repo = Repo.new(@temp_repo_path, :create => true, :is_bare => true)
        @index = RJGit::Plumbing::Index.new(@repo)
        @msg = "Message"
        @auth = RJGit::Actor.new("test", "test@repotag.org")
      end
      
      it "has a treemap" do
        @index.treemap.should be_kind_of Hash
      end
      
      it "adds blobs to the treemap" do
        @index.add("test", "Test")
        @index.treemap["test"].should == "Test"
      end
      
      it "adds trees to the treemap" do
        @index.add("tree/blob", "Test")
        @index.treemap["tree"].should == {"blob" => "Test"}
      end
      
      it "adds items to delete to the treemap" do
        @index.delete("tree/blob")
        @index.treemap["tree"]["blob"].should == :delete
      end
      
      it "adds commits to an empty repository" do
        res, log = @index.commit(@msg, @auth)
        res.should == "NEW"
        @repo.blob("test").data.should == "Test"
        @repo.commits.first.parents.should be_empty
      end
      
      it "adds commits with a parent commit" do
        @index.add("tree/blob", "Test")
        res, log = @index.commit(@msg, @auth)
        res.should == "FAST_FORWARD"
        @repo.blob("tree/blob").data.should == "Test"
        @repo.commits.first.parents.should_not be_empty
      end
      
      it "returns log information after commit" do
        @index.add("tree/blob2", "Tester")
        res, log = @index.commit(@msg, @auth)
        log[:added].select {|x| x.include?("tree")}.first.should include(:tree)
      end
      
      it "commits to a non-default branch" do
        msg = "Branch test"
        @index.add("tree/blob3", "More testing")
        res, log = @index.commit(msg, @auth, nil, nil, "refs/heads/newbranch")
        @repo.commits("newbranch").first.message.should == msg
      end
      
      it "allows setting multiple parents for a commit" do
        @index.delete("tree/blob2")
        parents = [@repo.commits.first, @repo.commits.last]
        res, log = @index.commit(@msg, @auth, parents)
        @repo.commits.first.parents.length.should == 2
      end
      
      it "allows setting the departure tree when building a new commit" do
        @index.add("newtree/blobinnewtree", "contents")
        res, log = @index.commit(@msg, @auth)
        tree = @repo.tree("newtree").jtree
        @index.add("secondblob", "other contents")
        res, log = @index.commit(@msg, @auth, nil, tree)
        @repo.blob("blobinnewtree").data.should == "contents"
        @repo.blob("secondblob").data.should == "other contents"
      end
      
      it "tells whether a response code indicates a successful response" do
        ["NEW", "FAST_FORWARD"].each do |s|
          RJGit::Plumbing::Index.successful?(s).should == true
        end
        RJGit::Plumbing::Index.successful?("FAILED").should == false
      end
      
      after(:all) do
        remove_temp_repo(@temp_repo_path)
        @repo = nil
      end
    
    end
    
    describe RJGit::Plumbing::TreeBuilder do
      before(:all) do
        @temp_repo_path = get_new_temp_repo_path(true)
        @repo = Repo.new(@temp_repo_path, :create => true, :is_bare => true)
        @tb = RJGit::Plumbing::TreeBuilder.new(@repo)
      end
      
      it "initializes with the right defaults" do
        @tb.object_inserter.should be_kind_of org.eclipse.jgit.lib.ObjectInserter
        @tb.treemap.should == {}
        @tb.log.should == {:deleted => [], :added => [] }
      end
      
      it "adds and deletes objects to a tree" do
        @tb.treemap = {"newtest/bla" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        tree.should be_kind_of org.eclipse.jgit.lib.ObjectId
        
        treewalk = TreeWalk.new(@repo.jrepo)
        treewalk.add_tree(tree)
        treewalk.set_recursive(true)
        objects = []
        while treewalk.next
          objects << treewalk.get_path_string
        end
        objects.should include("newtest/bla")
        
        @tb.treemap = {"newtest" => :delete}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        
        treewalk = TreeWalk.new(@repo.jrepo)
        treewalk.add_tree(tree)
        treewalk.set_recursive(true)
        objects = []
        while treewalk.next
          objects << treewalk.get_path_string
        end
        objects.should_not include("newtest/bla")
      end
      
      it "logs information about added and deleted objects" do
        @tb.treemap = {"newtest" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        @tb.log[:added].first.should include(:blob)
        @tb.log[:deleted].should be_empty
        @tb.treemap = {"newtest" => :delete}
        @tb.build_tree(tree)
        @tb.log[:deleted].first.should include(:blob)
        @tb.log[:deleted].first.should include("newtest")
      end
      
      it "does not log information about trees that contain no added objects" do
        @tb.treemap = {"newtest" => "test"}
        tree = @tb.build_tree(@repo.jrepo.resolve("refs/heads/master^{tree}"))
        @tb.init_log
        @tb.treemap = {"newtest" => :delete}
        @tb.build_tree(tree)
        @tb.log[:added].should be_empty
      end
      
      it "tells whether a give hashmap contains no added blobs" do
        @tb.only_contains_deletions({'test' => {'test' => :delete}}).should == true
        @tb.only_contains_deletions({'test' => {'test' => :delete, 'test2' => 'content'}}).should == false
      end
      
      after(:all) do
        remove_temp_repo(@temp_repo_path)
        @repo = nil
      end
      
    end
    
  end
  
  describe "helper methods" do
    specify {RJGit.repository_type("A String").should be_nil}
    specify {RJGit.tree_type("A String").should be_nil}
    specify {RJGit.actor_type("A String").should be_nil}
    specify {RJGit.commit_type("A String").should be_nil}
    specify {RJGit.underscore("CamelCaseToSnakeCase").should == 'camel_case_to_snake_case'}
  end
  
  after(:all) do
    @bare_repo = nil
  end
end