require 'spec_helper'

describe LocalRefWriter do

  before(:each) do
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
    @writer = LocalRefWriter.new(@repo.jrepo.get_all_refs, @repo.path)
  end
  
  it "has a path variable set at initialization" do
    expect(@writer.path).to eql @repo.path
  end
  
  it "writes to the specified file path under the repository's path" do
    filename = File.join('info','nonexistent')
    newfile = File.join(@repo.path, filename)
    expect(File.exists?(newfile)).to be false
    @writer.writeFile(filename, "Test".to_java_bytes)
    expect(File.exists?(newfile)).to be true
  end
  
  it "inherits the write_info_refs method from its JGit superclass" do
    expect(@writer.method(:write_info_refs).owner).to eql Java::OrgEclipseJgitLib::RefWriter
  end
  
  it "throws a Java IOException when the destination file is not writable" do
    expect{ @writer.writeFile("","Test".to_java_bytes) }.to raise_error(IOException)
  end
  
  after(:each) do
    remove_temp_repo(@temp_repo_path)
    @repo = nil
    @writer = nil
    @temp_repo_path = nil
  end

end

describe Repo do

  context "with read-only access" do
    
    before(:each) do
      @create_new = true
      @repo = Repo.new(TEST_REPO_PATH) # Test with both a bare and a non-bare repository
      @bare_repo = Repo.new(TEST_BARE_REPO_PATH)
    end

    it "determines if the repository is valid" do
      tmp_path = get_new_temp_repo_path
      
      expect(tmp_path).to_not exist
      new_repo = Repo.new(tmp_path, :is_bare => false, :create => false)
      expect(new_repo).to_not be_valid
      new_repo.create!
      expect(new_repo).to be_valid
      FileUtils.rm_rf(File.join(tmp_path, '.git'))
      expect(new_repo).to_not be_valid
      remove_temp_repo(tmp_path)
      
      expect(tmp_path).to_not exist
      bare_new_repo = Repo.new(tmp_path, :is_bare => true, :create => false)
      expect(bare_new_repo).to_not be_valid
      bare_new_repo.create!
      expect(bare_new_repo).to be_valid
      FileUtils.rm_rf(File.join(tmp_path, 'objects'))
      expect(bare_new_repo).to_not be_valid
      remove_temp_repo(tmp_path)
    end

    it "defaults to a non-bare repository path" do
      expect(@repo.path).to eql File.join(TEST_REPO_PATH, '.git')
    end

    it "has a bare path for bare repositories" do
      expect(File.basename(@bare_repo.path)).to_not eql ".git"
    end
    
    it "is bare for a new repository only if specified" do
      repo = Repo.new(get_new_temp_repo_path(true), :is_bare => true)
      expect(repo).to be_bare
      repo = Repo.new(get_new_temp_repo_path)
      expect(repo).to_not be_bare
    end
    
    it "allows the user to set bare even if a .git dir exists in the path" do
      repo = Repo.new(TEST_REPO_PATH, :is_bare => true)
      expect(repo).to be_bare
    end
    
    it "allows the user to set non-bare even if a .git dir does not exist in the path" do
      repo = Repo.new(TEST_BARE_REPO_PATH, :is_bare => false)
      expect(repo).to_not be_bare
    end
    
    it "creates a new repository on disk immediately" do
      tmp_path = get_new_temp_repo_path
      expect(tmp_path).to_not be_a_directory
      new_repo = Repo.new(tmp_path, create: @create_new)
      expect(tmp_path).to be_a_directory
      remove_temp_repo(tmp_path)
      expect(new_repo).to_not be_bare
    end
    
    it "creates a new bare repository on disk immediately" do
      tmp_path = get_new_temp_repo_path(true)
      expect(tmp_path).to_not be_a_directory
      new_repo = Repo.new(tmp_path, :is_bare => true, :create => @create_new)
      expect(tmp_path).to be_a_directory
      remove_temp_repo(tmp_path)
      expect(new_repo).to be_bare
    end
    
    it "creates an existing repository object on disk" do
      tmp_path = get_new_temp_repo_path
      new_repo = Repo.new(tmp_path, :is_bare => false, :create => false)
      expect(tmp_path).to_not be_a_directory
      new_repo.create!
      expect(tmp_path).to be_a_directory
      remove_temp_repo(tmp_path)
      expect(new_repo).to_not be_bare
    end

    it "creates a new bare repository if specified" do
      tmp_path = get_new_temp_repo_path(true)
      expect(tmp_path).to_not be_a_directory
      new_bare_repo = Repo.new(tmp_path, :is_bare => true, :create => @create_new)
      expect(tmp_path).to be_a_directory
      remove_temp_repo(tmp_path)
      expect(new_bare_repo).to be_bare
    end
    
    it "wraps a JGit repository object" do
      jrepo = @repo.jrepo
      repo = Repo.new_from_jgit_repo(jrepo)
      expect(repo).to be_valid
    end

    it "creates a new repository on disk" do
      tmp_path = get_new_temp_repo_path(true) # bare repository
      expect(tmp_path).to_not be_a_directory
      new_bare_repo = Repo.create(tmp_path, :is_bare => true)
      result = expect(tmp_path).to be_a_directory
      remove_temp_repo(tmp_path)
      result
      
      tmp_path = get_new_temp_repo_path # non-bare repository
      expect(tmp_path).to_not exist
      new_repo = Repo.create(tmp_path, :is_bare => false)
      result = expect(tmp_path).to exist
      remove_temp_repo(tmp_path)
      result
    end
    
    it "informs us whether it is bare" do
      expect(@repo).to_not be_bare
      expect(@bare_repo).to be_bare
    end

    it "has a reference to a JGit Repository object" do
      expect(@repo.jrepo).to be_a org.eclipse.jgit.lib.Repository
    end

    it "has a config" do
      expect(@bare_repo.config).to be_a RJGit::Configuration
    end
    
    it "lists the current branch" do
      expect(@repo.branch).to eq "refs/heads/master"
    end

    it "lists its branches" do
      result = @repo.branches
      expect(result).to be_an Array
      expect(result).to include("refs/heads/master")
    end

    it "lists its commits" do
      expect(@repo.commits).to be_an Array
      expect(@repo.commits.length).to eq 8
    end
    
    it "returns the latest commit (HEAD)" do    
      expect(@repo.head.committed_date).to eq(DateTime.parse("2015-04-03 14:27:02 +0200").to_time)
    end
    
    it "lists its tags in name-id pairs" do
      expect(@bare_repo.tags(lightweight=true)).to be_a Hash
      expect(@bare_repo.tags(true)["annotated"]).to eq "b7f932bd02b3e0a4228ee7b55832749028d345de"
    end

    it "lists its tags as Tags" do
      expect(@bare_repo.tags).to be_a Hash
      tag = @bare_repo.tags['annotated']
      expect(tag).to be_a Tag
      expect(tag.id).to eq "b7f932bd02b3e0a4228ee7b55832749028d345de"
    end

    it "returns a Blob by name" do
      blob = @bare_repo.blob('lib/grit.rb')
      expect(blob).to_not be_nil
      expect(blob.id).to match /77aa887449c28a922a660b2bb749e4127f7664e5/
      expect(blob.name).to eq 'grit.rb'
      expect(blob.jblob).to be_a org.eclipse.jgit.revwalk.RevBlob
    end

    it "returns a Tree by name" do
      tree = @bare_repo.tree('lib')
      expect(tree).to_not be_nil
      expect(tree.id).to match /aa74200714ce8190b38211795f974b4410f5a9d0/
      expect(tree.name).to eq 'lib'
      expect(tree.jtree).to be_a org.eclipse.jgit.revwalk.RevTree
    end
    
    it "finds objects of all types by SHA" do
      expect(@bare_repo.find(@bare_repo.head.tree.trees.first.id, :tree)).to be_a Tree
      expect(@bare_repo.find(@bare_repo.head.tree.blobs.first.id, :blob)).to be_a Blob
      expect(@bare_repo.find(@bare_repo.tags.first.last.id, :tag)).to be_a Tag
      expect(@bare_repo.find(@bare_repo.head.id, :commit)).to be_a Commit
      expect(@bare_repo.find(@bare_repo.head.id)).to be_a Commit
      expect(@bare_repo.find(@bare_repo.head.id, :notdefined)).to be_nil
      expect(@bare_repo.find("dsa", :commit)).to be_nil
      expect(@bare_repo.find("aa74200714ce8190b38211795f974nonexistent")).to be_nil
      expect(@bare_repo.find(@bare_repo.head.id, :blob)).to be_nil
    end

    after(:each) do
      @repo = nil
      @bare_repo = nil
    end
  end
  
  context "with write/commit access" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end
    
    it "adds files to itself" do
      File.open(File.join(@temp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
      @repo.add("rspec-addfile.txt")
      expect(@repo.jrepo.read_dir_cache.find_entry("rspec-addfile.txt")).to eq 6
    end
  
    it "creates a branch" do
      @repo.create_branch('rspec-branch')
      expect(@repo.branches).to include('refs/heads/rspec-branch')
    end
    
    it "deletes a branch" do
      @repo.delete_branch('refs/heads/alternative')
      expect(@repo.branches).to_not include('refs/heads/alternative')
    end
    
    it "renames a branch" do
      @repo.rename_branch('refs/heads/alternative', 'rspec-branch')
      expect(@repo.branches).to include('refs/heads/rspec-branch')
    end
    
    it "checks out a branch if clean" do
      result = @repo.git.checkout('refs/heads/alternative')
      expect(result[:success]).to be true
      expect(result[:result]).to eq 'refs/heads/alternative'
    end
    
    it "does not switch branches if there are conflicts" do
      File.open(File.join(@temp_repo_path, "rspec-conflictingfile.txt"), 'w') {|file| file.write("This is a new file.") }
      @repo.add("rspec-conflictingfile.txt")
      @repo.commit("Creating a conflict - step 1")
      @repo.create_branch('conflict_branch')
      File.open(File.join(@temp_repo_path, "rspec-conflictingfile.txt"), 'a') {|file| file.write("A second line - no conflict yet.") }
      @repo.add("rspec-conflictingfile.txt")
      @repo.commit("Creating a conflict - step 2")
      @repo.checkout('refs/heads/conflict_branch')
      File.open(File.join(@temp_repo_path, "rspec-conflictingfile.txt"), 'a') {|file| file.write("A second line - this should lead to a conflict.") }
      result = @repo.checkout('refs/heads/master')
      expect(result[:success]).to be false
      expect(result[:result]).to include 'rspec-conflictingfile.txt'
      expect(@repo.branch).to eq 'refs/heads/conflict_branch'
    end
    
    it "commits files to the repository" do
      expect(RJGit::Porcelain.ls_tree(@repo)).to have(6).items
      File.open(File.join(@temp_repo_path, "newfile.txt"), 'w') {|file| file.write("This is a new file to commit.") }
      @repo.add("newfile.txt")
      @repo.commit("Committing a test file to a test repository.")
      expect(RJGit::Porcelain.ls_tree(@repo)).to have_at_least(7).items
      expect(@repo).to respond_to(:commit).with(2).arguments
    end
    
    it "removes files from the index and the file system" do
      File.open(File.join(@temp_repo_path, "remove_file.txt"), 'w') {|file| file.write("This is a file to remove.") }
      @repo.add("remove_file.txt")
      @repo.commit("Added remove_file.txt")
      expect("#{@temp_repo_path}/remove_file.txt").to exist
      @repo.remove("remove_file.txt")
      diff = RJGit::Porcelain.diff(@repo, {:cached => true}).first
      @repo.commit("Removed file remove_file.txt.")
      expect(diff[:oldpath]).to eq 'remove_file.txt'
      expect(diff[:changetype]).to eq 'DELETE'
      expect("#{@temp_repo_path}/remove_file.txt").to_not exist
    end
    
    it "updates a ref" do
      new_tree = Tree.new_from_hashmap(@repo, {"bla" => "bla"}, @repo.head.tree)
      c = Commit.new_with_tree(@repo, new_tree, "Commit message", Actor.new("test","test@test"))
      expect(@repo.head.id).to_not eq c.id
      expect(@repo.update_ref(c)).to eq "FAST_FORWARD"
      expect(@repo.head.id).to eq c.id
    end
    
    it "updates the server info files" do
      server_info_files = [File.join(@repo.path, 'info','refs'), File.join(@repo.path, 'objects','info','packs')]
      contents = []
      server_info_files.each {|path| f = File.new(path, "r"); contents << f.read; f.close }
      server_info_files.each {|path| f = File.delete(path)}
      @repo.update_server_info
      server_info_files.each_with_index do |path,i|
        f = File.new(path, "r")
        new_contents = ""
	      f.each_line do |line|
          new_contents = new_contents + line unless line.include?("refs/heads/.svn/") # JGit (unlike git) also searches directories under refs/heads starting with ".", so it finds some refs in /refs/heads/.svn that git-update-server does not find. See Repo.update_server_info. For now, just filter these lines out.
        end
        expect(new_contents).to eql contents[i]
        f.close
      end
    end
    
    after(:each) do
      remove_temp_repo(@temp_repo_path)
      @repo = nil
    end
  end
  
end
