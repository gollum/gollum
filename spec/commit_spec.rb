require 'spec_helper'

describe "A Commit object" do

  before(:all) do
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @bare_repo = Repo.new(@temp_bare_repo_path, {:bare => true}, false)
    @commit = @bare_repo.commits[0]
  end

  after(:all) do
    remove_temp_repo(File.dirname(@temp_bare_repo_path))
  end

  it "should have an id" do
    @commit.id.should match /ca8a30f5a7f0f163bbe3b6f0abf18a6c83b0687a/
  end

  it "should have an actor" do
    actor = @commit.actor
    actor.name.should == 'Scott Chacon'
    actor.email.should == 'schacon@gmail.com'
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

  it "should have a test commit" do
    pending("The actual code to commit something is not yet implemented.")
    Git.any_instance.should_receive(:commit).and_return(fixture('commit'))
    pending("Repo#commit_index is not yet implemented")
    results = @bare_repo.commit_index('my message')
    result.should match /Created commit/
  end

end
