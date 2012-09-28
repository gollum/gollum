require 'spec_helper'

describe "A Commit object" do
    
  before(:each) do
    # @r = Repo.new('some_repo_path_fixture', :is_bare => true)
  end
  
  it "should have an id" do
    pending
  end
  it "should have an author" do
    pending
  end
  it "should have a message" do
    pending
  end
  
  it "should have a count" do
    pending
    # Commit.count(@r, 'master').should eql 107
  end
  
  describe "Commit" do
    it "should test commit" do 
      Git.any_instance.expects(:commit).returns(fixture('commit'))
      results = @repo.commit_index('my message')
      assert_match /Created commit/, results
    end
  end
  
end