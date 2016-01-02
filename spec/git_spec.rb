require 'spec_helper'

describe RubyGit do
  
  it "returns a status object" do
    repo = Repo.new(TEST_REPO_PATH)
    expect(repo.git.status.get_modified.to_a).to be_empty
    expect(repo.git.status.is_clean).to be true
  end
  
  context "when logging" do
    it "returns log information" do
      repo = Repo.new(TEST_REPO_PATH)
      messages = repo.git.log
      expect(messages).to_not be_empty
      expect(messages.first.message).to match /Renamed the follow rename file/
      messages = repo.git.log("deconstructions.txt")
      expect(messages.first.message).to match /More interesting postmodern comments./
      messages = repo.git.log(nil, "HEAD", {max_count: 1})
      expect(messages.count).to eq 1
      messages = repo.git.log(nil, "HEAD", {max_count: 1, skip: 1})
      expect(messages.first.message).to_not match /More interesting postmodern comments./
    end
  
    it "returns log information for an array of refs" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      expect(ids).to have(8).ids
      logs = repo.git.logs(ids, max_count: 1)
      expect(logs).to have(8).logs
      first_log = logs.first
      expect(first_log).to have(1).logs
      expect(first_log.first.message).to match /Renamed the follow rename file/
    end
  
    it "returns log information for a range of commits" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      logs = repo.git.log(nil, "HEAD", since: '83fc72f692a717cfffd77b32f705c4063357e6a6', until: '55ca9d4360c522d38bc73ef9cce81c2f72c413d5')
      expect(logs).to have(1).logs
      expect(logs.first.message).to match /Renamed the follow rename file/
    end
        
    it "returns log information excluding certain refs" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      logs = repo.git.log(nil, "HEAD", not: ['ad982fe7d4787928daba69bf0ba44a59c572ccd7'])
      expect(logs).to have(7).logs
      expect(logs.map(&:id)).to_not include 'ad982fe7d4787928daba69bf0ba44a59c572ccd7'
    end
  
    it "follows renames" do
      repo = Repo.new(TEST_REPO_PATH)
      messages = repo.git.log("follow-rename.txt", "HEAD", follow: true)
      expect(messages.count).to eq 2
      expect(messages[1].message).to match /for following renames/
    end    
    
  end
   
  context "when creating tags" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end

    it "tag with only a name" do
      expect(@repo.tags).to have(0).tags
      @repo.git.tag('v0.0')
      expect(@repo.tags).to have_exactly(1).tags
    end
  
    it "tag with a name and message" do
      expect(@repo.tags).to have(0).tags
      @repo.git.tag('v0.0', 'initial state commit')
      expect(@repo.tags).to have_exactly(1).tags
      expect(@repo.tags['v0.0'].full_message).to match /initial state commit/
    end

    it "tag with a specific commit or revision" do
      commit = @repo.commits.first
      @repo.git.tag('v0.0', 'initial state commit for a specific commit', commit)
      expect(@repo.tags).to have_exactly(1).tags
    end
    
    it "tag with specific actor information" do
      actor = Actor.new('Rspec Examplar', 'rspec@tagging.example')
      @repo.git.tag('v0.0', 'initial state commit', nil, actor)
      expect(@repo.tags).to have_exactly(1).tags
      expect(@repo.tags["v0.0"].actor.name).to eq 'Rspec Examplar'
    end
    
    after(:each) do
      remove_temp_repo(@temp_repo_path)
      @repo = nil
    end
  end
  
  context "committing with settings" do

    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      @git = @repo.git
      @actor = Actor.new('Rspec Examplar', 'rspec@tagging.example')
    end
    
    it "commits files with all jgit settings" do
      File.open(File.join(@temp_repo_path, "rspec-committest.txt"), 'w') {|file| file.write("This file is for comitting.")}
      @repo.add("rspec-comittest.txt")
      options = {all: false, amend: false, author: @actor, committer: @actor, insert_change_id: false, only_paths: ["rspec-comittest.txt"], reflog_comment: "test"}
      [:set_all, :set_amend, :set_author, :set_committer, :set_insert_change_id, :set_only, :set_reflog_comment].each {|message| expect_any_instance_of(org.eclipse.jgit.api.CommitCommand).to receive(message)}
      commit = @git.commit("Creating a commit for testing jgit setters", options)
    end
    
     after(:each) do
      remove_temp_repo(@temp_repo_path)
    end
    
  end
  
  context "when merging" do

    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      @repo.create_branch('branch_for_merging')
      @repo.checkout('branch_for_merging')
    end
    
    it "merges a commit with current branch" do
      # add and commit new file to new branch
      File.open(File.join(@temp_repo_path, "rspec-mergetest.txt"), 'w') {|file| file.write("This file is for merging.")}
      @repo.add("rspec-mergetest.txt")
      commit = @repo.commit("Creating a commit for merging")
      # change to 'master' branch
      @repo.checkout('master')
      # merge commit from branch with 'master'
      @repo.git.merge(commit)
      # check for successful merge
      listing = RJGit::Porcelain.ls_tree(@repo)
      listing.select! {|entry| entry[:path] == "rspec-mergetest.txt" }
      expect(listing).to have(1).entry
    end
    
    it "returns an Array with conflict names when there are conflicts" do
      File.open(File.join(@temp_repo_path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
      @repo.add("materialist.txt")
      commit = @repo.commit("Creating a conflict - step 1")
      @repo.checkout('master')
      File.open(File.join(@temp_repo_path, "materialist.txt"), 'a') {|file| file.write("\n Same line - different string.") }
      @repo.add("materialist.txt")
      @repo.commit("Creating a conflict - step 2")
      result = @repo.git.merge(commit)
      expect(result).to include('materialist.txt')
    end
    
    after(:each) do
      remove_temp_repo(@temp_repo_path)
    end
    
  end
  
  context "cloning a non-bare repository" do
    before(:each) do
      @repo = Repo.new(TEST_REPO_PATH) 
      @remote = TEST_REPO_PATH
      @local  = get_new_temp_repo_path
    end
    
    it "creates a new local repository" do
      clone = @repo.git.clone(@remote, @local)
      expect(clone.path).to eq File.join(@local, '/.git')
      expect(File.exist?(File.join(@local, 'homer-excited.png'))).to be true
    end
    
    it "clones a specific branch if specified" do
      clone = @repo.git.clone(@remote, @local, {branch: 'refs/heads/alternative'})
      expect(clone.branches).to have_exactly(1).branch
      expect(clone.branches.first).to eq 'refs/heads/alternative'
    end
    
    it "clones all branches if specified" do
      clone = @repo.git.clone(@remote, @local, {branch: :all})
      expect(clone.branches).to have_at_least(1).branch
      
      skip "This specs fails because of a JGit bug with CloneCommand#set_clone_all_branches(true)"
    end
    
    it "clones with credentials" do
      clone = @repo.git.clone(@remote, @local, username: 'rspec', password: 'Hahmeid7')
      expect(clone.path).to eq File.join(@local, '/.git')
      expect(File.exist?(File.join(@local, 'homer-excited.png'))).to be true
    end
    
    after(:each) do
      remove_temp_repo(@local)
    end
    
  end
  
  context "cloning a bare repository" do
    before(:each) do
      remote = TEST_BARE_REPO_PATH
      @local  = get_new_temp_repo_path(true)
      @clone = RubyGit.clone(remote, @local, is_bare: true)
    end
    
    it "is be bare" do
      expect(@clone).to be_bare
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
    
    it "applies a patch from a String" do
      patch = fixture('postpatriarchialist.patch')
      result = @repo.git.apply_patch(patch)
      expect(result).to have(1).changed_file
      expect(result.first).to match /postpatriarchialist.txt/
    end
    
    it "applies a patch from a file" do
      patch = File.join(File.dirname(__FILE__), 'fixtures', 'postpatriarchialist.patch')
      result = @repo.git.apply_file(patch)
      expect(result).to have(1).changed_file
      expect(result.first).to match /postpatriarchialist.txt/
    end
    
    after(:each) do
      remove_temp_repo(@temp_repo_path)
    end
    
  end
  
  describe "push and pull" do 
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @remote = Repo.new(@temp_repo_path)
      @local = @remote.git.clone(@remote.path, get_new_temp_repo_path)
    end
    
    context "pulling from another repository" do
      before(:each) do
        File.open(File.join(@remote.path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
        @remote.add("materialist.txt")
        @commit = @remote.commit("Making a change for pushing and pulling specs")
      end
    
      it "pulls commits from a local clone" do
        expect(@local.commits).to have(8).commits
        @local.git.pull("origin", "master")
        expect(@local.commits).to have(9).commits
      end
      
      it "pulls commits from a local clone with rebase" do
        expect(@local.commits).to have(8).commits
        @local.git.pull(nil, nil, rebase: true)
        expect(@local.commits).to have(9).commits
      end
    
      it "pulls commits from a local clone with credentials" do
        expect(@local.commits).to have(8).commits
        @local.git.pull(nil, nil, username: 'rspec', password: 'Hahmeid7')
        expect(@local.commits).to have(9).commits
      end
    
    end
  
    context "pushing to another repository" do
        before(:each) do
          File.open(File.join(@local.path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
          @local.add("materialist.txt")
          @commit = @local.commit("Making a change for pushing and pulling specs")
        end
      
      it "pushes all changes to a local clone" do
        expect(@remote.commits).to have(8).commits
        @local.git.push_all('origin')
        expect(@remote.commits).to have(9).commits
      end
      
      it "pushes all changes to a local clone with credentials" do
        expect(@remote.commits).to have(8).commits
        @local.git.push_all('origin', username: 'rspec', password: 'Hahmeid7')
        expect(@remote.commits).to have(9).commits
      end
      
      it "pushes a specific ref to a local clone" do
        expect(@remote.commits).to have(8).commits
        @local.git.push('origin', ["master"], username: 'rspec', password: 'Hahmeid7')
        expect(@remote.commits).to have(9).commits
      end
      
    end
    
    after(:each) do
      remove_temp_repo(@temp_repo_path)
      remove_temp_repo(File.dirname(@local.path))
    end
    
  end
  
  context "cleaning a repository" do
    before(:each) do
      @temp_repo_path = get_new_temp_repo_path
      @repo = Repo.create(@temp_repo_path)
  	  File.open(File.join(@temp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
    end
    
    it "removes untracked files from the working tree" do
      @repo.clean
      expect(File.exist?(File.join(@temp_repo_path, "rspec-addfile.txt"))).to be false
    end
    
    context "after adding files" do
      
      before(:each) do
        @repo.add("#{@temp_repo_path}/rspec-addfile.txt")
        @entry = RJGit::Porcelain.diff(@repo).first
      end
      it "removes added files from the index" do
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean
        @entry = RJGit::Porcelain.diff(@repo).first
        expect(@entry).to be_nil
      end
    
      it "performs a dry run when asked" do
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean(dryrun: true)
        @entry = RJGit::Porcelain.diff(@repo).first
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
      end
    end
    
    after(:each) do
      @repo = nil
      remove_temp_repo(@temp_repo_path)
    end
  end
  
  context "resetting a (part of) a repository" do
    before(:each) do
      #Create a temporary repository
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      
      #Open the 'materialist.txt' file in the repo and add the text "fluffy bunny"
      File.open(File.join(@temp_repo_path,"materialist.txt"), "a+") do |f|
        @before_write = f.read
        f.write("fluffy bunny")
      end
    end

    it "reverts commits" do
      @repo.add("materialist.txt")
      to_revert = @repo.commit("Added test for reverting.")
      reverted_commit = @repo.git.revert([to_revert])
      expect(@repo.commits.first.id).to eq reverted_commit.id
    end
    
    it "handles errors for revert"
        
    it "resets the hard way" do
      #reset the 'materialist.txt' file to the current head, through the HARD way
      ref = @repo.commits.first
      @repo.git.reset(ref)
      
      #Check if the hard reset worked correctly
      File.open(File.join(@temp_repo_path,"materialist.txt"), "r") do |f|
        expect(f.read).to eq @before_write
      end
    end
      
    it "unstages files" do
      paths = ["materialist.txt"]
      @repo.add("#{paths.first}")
      expect(@repo.git.status.getChanged.to_a).to include(paths.first)
      ref = @repo.commits.first
      @repo.git.reset(ref, nil, paths)
      expect(@repo.git.status.getChanged.to_a).to_not include(paths.first)
    end
    
    it "returns nil if mode is not valid" do
      ref = @repo.commits.first
      expect(@repo.git.reset(ref, "NONEXISTENT")).to be_nil
    end
    
    it "does not reset any type together with specified file paths" do
      mode = "MERGE"
      paths = ["materialist.txt"]
      ref = @repo.commits.first
      expect { @repo.git.reset(ref, mode, paths) }.to raise_error org.eclipse.jgit.api.errors.JGitInternalException
    end
    
    after(:each) do
      @repo = nil
      remove_temp_repo(@temp_repo_path)
    end
    
  end

end


