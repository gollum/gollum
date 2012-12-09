require 'spec_helper'

describe Repo do

  context "with read-only access" do
    
    before(:each) do
      @create_new = true
      @repo = Repo.new(TEST_REPO_PATH) # Test with both a bare and a non-bare repository
      @bare_repo = Repo.new(TEST_BARE_REPO_PATH, {:bare => true}, false)
    end

    it "should default to a non-bare repository path" do
      @repo.path.should eql TEST_REPO_PATH + '/.git'
    end

    it "should have a bare repository path if specified" do
      File.basename(@bare_repo.path).should_not eql ".git"
    end

    it "should create a new repository if specified" do
      tmp_path = get_new_tmprepo_path
      tmp_path.should_not exist
      new_repo = Repo.new(tmp_path, {:bare => false}, @create_new)
      result = tmp_path.should exist
      remove_temp_repo(tmp_path)
      result
    end

    it "should create a new bare repository if specified" do
      tmp_path = get_new_tmprepo_path(true)
      tmp_path.should_not be_a_directory
      new_bare_repo = Repo.new(tmp_path, {:bare => true}, @create_new)
      result = tmp_path.should be_a_directory
      remove_temp_repo(tmp_path)
      result
    end

    it "should create the repository on disk" do
      tmp_path = get_new_tmprepo_path(true) # bare repository
      tmp_path.should_not be_a_directory
      new_bare_repo = Repo.create(tmp_path, {:bare => true})
      result = tmp_path.should be_a_directory
      remove_temp_repo(tmp_path)
      result
      
      tmp_path = get_new_tmprepo_path # non-bare repository
      tmp_path.should_not exist
      new_repo = Repo.create(tmp_path, {:bare => false})
      result = tmp_path.should exist
      remove_temp_repo(tmp_path)
      result
    end
    
    it "should tell us whether it is bare" do
      @repo.should_not be_bare
      @bare_repo.should be_bare
    end

    it "should have a reference to a JGit Repository object" do
      @repo.jrepo.should be_a org.eclipse.jgit.lib.Repository
    end

    it "should list the current branch" do
      @repo.branch.should == "refs/heads/master"
    end

    it "should list its branches" do
      result = @repo.branches
      result.should be_an Array
      result.should include("refs/heads/master")
    end

    it "should list its commits" do
      @repo.commits.should be_an Array
      @repo.commits.length.should > 3
    end

    it "should return a Blob by name" do
      blob = @bare_repo.blob('lib/grit.rb')
      blob.should_not be_nil
      blob.id.should match /77aa887449c28a922a660b2bb749e4127f7664e5/
      blob.name.should == 'grit.rb'
      blob.jblob.should be_a org.eclipse.jgit.revwalk.RevBlob
    end

    it "should return a Tree by name" do
      tree = @bare_repo.tree('lib')
      tree.should_not be_nil
      tree.id.should match /aa74200714ce8190b38211795f974b4410f5a9d0/
      tree.name.should == 'lib'
      tree.jtree.should be_a org.eclipse.jgit.revwalk.RevTree
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
    
    it "should add files to itself" do
      File.open("#{@temp_repo_path}/rspec-addfile.txt", 'w') {|file| file.write("This is a new file to add.") }
      @repo.add("rspec-addfile.txt")
      @repo.jrepo.read_dir_cache.find_entry("rspec-addfile.txt").should > 0
    end
  
    it "should commit files to the repository" do
      RJGit::Porcelain.ls_tree(@repo).size.should == 5
      File.open("#{@temp_repo_path}/newfile.txt", 'w') {|file| file.write("This is a new file to commit.") }
      @repo.add("newfile.txt")
      @repo.commit("Committing a test file to a test repository.")
      @diff = RJGit::Porcelain.diff(@repo)
      $stderr.puts "\n\n\n" + @diff.inspect + "\n\n\n"
      RJGit::Porcelain.ls_tree(@repo).size.should > 5
    end
    
    it "should remove files from the index and the file system" do
      File.open("#{@temp_repo_path}/remove_file.txt", 'w') {|file| file.write("This is a file to remove.") }
      @repo.add("remove_file.txt")
      @repo.commit("Added remove_file.txt")
      "#{@temp_repo_path}/remove_file.txt".should exist
      @repo.remove("remove_file.txt")
      @diff = RJGit::Porcelain.diff(@repo).first
      $stderr.puts "\n\n\n" + @diff.inspect + "\n\n\n"
      @diff[:oldpath].should == 'remove_file.txt'
      @diff[:changetype].should == 'DELETE'
      "#{@temp_repo_path}/remove_file.txt".should_not exist
    end
    
    after(:each) do
      remove_temp_repo(File.dirname(@temp_repo_path))
      @repo = nil
    end
  end
  
end
