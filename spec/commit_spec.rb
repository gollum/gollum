require 'spec_helper'

describe "A Commit object" do
    
  before(:each) do
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @bare_repo = Repo.new(@temp_bare_repo_path, {:bare => true}, false)
  end
  
  it "should have an id" 
 
  it "should have an author" 
 
  it "should have a message" 
  
  it "should have a count" do
    pending
    # Commit.count(@repo, 'master').should eql 107
  end
  
  it "should have a test commit" do 
    pending("The actual code to commit something is not yet implemented.")
    Git.any_instance.should_receive(:commit).and_return(fixture('commit'))
    pending("Repo#commit_index is not yet implemented")
    results = @bare_repo.commit_index('my message')
    result.should match(/Created commit/)
  end
  
end