require 'spec_helper'

describe RubyGit do
  
  it "should return log information" do
    repo = Repo.new(TEST_REPO_PATH) 
    messages = repo.git.log
    messages.should_not be_empty
    messages.first.message.should match /Cleaning working directory/
  end
  
  it "should tag with commit or revision id" do
    bare_repo = Repo.new(TEST_BARE_REPO_PATH)
    pending "Should be done in a write-access situation"
  end
  
  it "should tag without commit or revision id" do
  end
  
  context "cloning a non-bare repository" do
    before(:each) do
      @repo = Repo.new(TEST_REPO_PATH) 
      @remote = TEST_REPO_PATH
      @local  = get_new_tmprepo_path 
    end
    
    it "should create a new local repository" do
      clone = @repo.git.clone(@remote, @local)
      clone.path.should == File.join(@local, '/.git')
      File.exist?(File.join(@local, 'homer-excited.png')).should be_true
    end
    
    it "should clone a specific branch if specified" do
      clone = @repo.git.clone(@remote, @local, {:branch => 'refs/heads/alternative'})
      clone.branches.size.should == 1
      clone.branches.first.should == 'refs/heads/alternative'
    end
    
    it "should clone all branches if specified" do
      clone = @repo.git.clone(@remote, @local, {:branch => :all})
      pending "This specs fails because of a JGit bug with CloneCommand#set_clone_all_branches(true)"
      clone.branches.size.should > 1
    end
    after(:each) do
      remove_temp_repo(@local)
    end
    
  end
  
  context "cloning a bare repository" do
    before(:each) do
      remote = TEST_BARE_REPO_PATH
      @local  = get_new_tmprepo_path(true)
      @clone = RubyGit.clone(remote, @local, {:bare => true})
    end
    
    it "should be bare" do
      @clone.should be_bare
    end
    
    after(:each) do
      remove_temp_repo(@local)
    end
  end
  
  it "should apply a patch to a file"
  
  context "cleaning a repository" do
    before(:each) do
      @tmp_repo_path = get_new_tmprepo_path
      @repo = Repo.create(@tmp_repo_path)
  	  File.open(File.join(@tmp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
    end
    
    it "should remove untracked files from the working tree" do
      @repo.clean
      File.exist?(File.join(@tmp_repo_path, "rspec-addfile.txt")).should be_false
    end
    
    context "after adding files" do
      
      before(:each) do
        @repo.add("#{@tmp_repo_path}/rspec-addfile.txt")
        @entry = RJGit::Porcelain.diff(@repo).first
      end
      it "should remove added files from the index" do
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean
        @entry = RJGit::Porcelain.diff(@repo).first
        @entry.should be_nil
      end
    
      it "should perform a dry run when asked" do
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean(:dryrun => true)
        @entry = RJGit::Porcelain.diff(@repo).first
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
      end
    end
    
    after(:each) do
      @repo = nil
      remove_temp_repo(@tmp_repo_path)
    end
  end
  
end


