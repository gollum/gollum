require 'spec_helper'

describe Repo do
    
  before(:all) do
    @create_new = true
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
    @bare_repo = Repo.new(@temp_bare_repo_path, {:bare => true}, false)
  end
    
  it "should default to a non-bare repository path" do
    @repo.path.should eql @temp_repo_path + '/.git'
  end
  
  it "should have a bare repository path if specified" do
    File.basename(@bare_repo.path).should_not eql ".git"
  end
  
  it "should create a new repository if specified" do
    filename = 'git_create_test' + Time.now.to_i.to_s + rand(300).to_s.rjust(3, '0')
    tmp_path = File.join("/tmp/", filename)
    new_repo = Repo.new(tmp_path, {:bare => false}, @create_new)
    File.exists?(tmp_path + '/.git').should eql true
  end

  it "should create a new bare repository if specified" do
    filename = 'git_create_bare_test' + Time.now.to_i.to_s + rand(300).to_s.rjust(3, '0')
    tmp_path = File.join("/tmp/", filename)
    new_bare_repo = Repo.new(tmp_path, {:bare => true}, @create_new)
    File.directory?(tmp_path).should eql true
  end
  
  it "should tell us whether it is bare" do
    @repo.bare?.should eql false
    @bare_repo.bare?.should eql true
  end
  
  it "should have a reference to a JGit Repository object" do
    @repo.repo.kind_of?(org.eclipse.jgit.lib.Repository).should eql true 
  end
  
  it "should list the current branch" do
    @repo.branch.should eql "master"
  end
  
  it "should list its branches" do
    result = @repo.branches
    result.is_a?(Array).should eql true
    result.include?("master").should eql true
  end
  
  it "should return its description" do
    result = @repo.description
    result.should eql fixtures("repo_description")
  end
  
  it "should list its commits" do
    pending
  end
  
  it "should add files to itself" do
    pending
  end
  
  it "should return a Blob by name" do
    blob = @repo.blob('blahblah')
    blob.is_a?(Blob).should eql true
  end
  
  it "should return a Tree by name" do
    pending
  end
  
end