require 'spec_helper'

describe Commit do

  before(:each) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH, {:bare => true}, false)
    @commit = @bare_repo.commits.first
  end

  after(:each) do
    @bare_repo = nil
  end

  it "should have an id" do
    @commit.id.should match /ca8a30f5a7f0f163bbe3b6f0abf18a6c83b0687a/
  end

  it "should have an actor" do
    actor = @commit.actor
    actor.name.should == 'Scott Chacon'
    actor.email.should == 'schacon@gmail.com'
  end
  
  it "should have a committer" do
    @commit.committer.name.should == 'Scott Chacon'
  end

  it "should have parent commits" do
    @commit.parents.should be_an Array
    @commit.parents.first.id.should match /3fa4e130fa18c92e3030d4accb5d3e0cadd40157/
  end
  
  it "should have a message" do
    @commit.message.should match /added a pure-ruby git library and converted the cat_file commands to use it/
  end
  
  it "should have a short message" do
    @commit.short_message.should match /pure-ruby git library/
  end

  it "should have a count" do
    @commit.count.should == 1
  end

  describe "#find_all(repo, ref, options)" do
    it "should return an empty array if nothing is found" do
      @commits = Commit.find_all(@bare_repo, 'remote42', {:limit => 10 })
      @commits.should be_an Array
      @commits.should be_empty
    end
    
    it "should return nil if something other than a repository is passed in" do
      Commit.find_all('A String Object', 'remote42', {:limit => 10 }).should be_nil
    end
    
  end 

end
