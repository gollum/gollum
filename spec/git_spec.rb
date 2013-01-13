require 'spec_helper'

describe RubyGit do
  
  it "should return log information" do
    repo = Repo.new(TEST_REPO_PATH) 
    messages = repo.git.log
    messages.should_not be_empty
    messages.first.message.should match /Cleaning working directory/
  end
  
  context "when creating tags" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end

    it "should tag with only a name" do
      @repo.tags.should have(0).tags
      @repo.git.tag('v0.0')
      @repo.tags.should have_exactly(1).tags
    end
  
    it "should tag with a name and message" do
      @repo.tags.should have(0).tags
      @repo.git.tag('v0.0', 'initial state commit')
      @repo.tags.should have_exactly(1).tags
      @repo.tags['v0.0'].full_message.should match /initial state commit/
    end

    it "should tag with a specific commit or revision" do
      commit = @repo.commits.first
      @repo.git.tag('v0.0', 'initial state commit for a specific commit', commit.jcommit)
      @repo.tags.should have_exactly(1).tags
    end
    
    it "should tag with specific actor information" do
      actor = Actor.new_from_name_and_email('Rspec Examplar', 'rspec@tagging.example')
      @repo.git.tag('v0.0', 'initial state commit', nil, actor)
      @repo.tags.should have_exactly(1).tags
      @repo.tags["v0.0"].actor.name.should == 'Rspec Examplar'
    end
    
    after(:each) do
      remove_temp_repo(File.dirname(@temp_repo_path))
      @repo = nil
    end
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
      clone.branches.should have_exactly(1).branch
      clone.branches.first.should == 'refs/heads/alternative'
    end
    
    it "should clone all branches if specified" do
      clone = @repo.git.clone(@remote, @local, {:branch => :all})
      clone.branches.should have_at_least(1).branch
      
      pending "This specs fails because of a JGit bug with CloneCommand#set_clone_all_branches(true)"
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
  
  context "patching" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end
    
    it "should apply from a String" do
      patch = fixture('postpatriarchialist.patch')
      #pending "new_material.patch fails with Java::OrgEclipseJgitApiErrors::PatchApplyException: Cannot apply: HunkHeader[5,7->5,7]"
      result = @repo.git.apply_patch(patch)
      result.should have(1).changed_file
      result.first.should match /postpatriarchialist.txt/
    end
    
    it "should apply a patch from a file" do
      patch = File.join(File.dirname(__FILE__), 'fixtures', 'postpatriarchialist.patch')
      # pending "mod_materialist.patch fails with Java::OrgEclipseJgitApiErrors::PatchApplyException: Cannot apply: HunkHeader[1,7->1,10]"
      result = @repo.git.apply_file(patch)
      result.should have(1).changed_file
      result.first.should match /postpatriarchialist.txt/
    end
    
    after(:each) do
      remove_temp_repo(File.dirname(@temp_repo_path))
    end
    
  end
  
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


