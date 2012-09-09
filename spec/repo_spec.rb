require 'spec_helper'

describe Repo do
    
  before(:each) do
    @repo = Repo.new(valid_repo_attributes[:path])
    @bare_repo = Repo.new(valid_repo_attributes[:path], {:bare => true}, false)
  end
  
  it "should default to a non-bare repository path" do
    @repo.path.should eql valid_repo_attributes[:path] + '/.git'
  end
  
  it "should have a bare repository path if specified" do
    File.basename(@bare_repo.path).should_not eql ".git"
  end
  
  it "should have a reference to a JGit Repository object" do
    @repo.repo.kind_of?(org.eclipse.jgit.lib.Repository).should eql true 
  end
  
  it "should list its branches" do
    pending
  end
  
  it "should add files to itself" do
    pending
  end
  
end