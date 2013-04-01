require 'spec_helper'

describe Tag do
  before(:each) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH, :bare => true, :create => false)
    @tag = @bare_repo.tags['v0.7.0']
  end
  
  it "should have an id" do
    @tag.id.should match /f0055fda16c18fd8b27986dbf038c735b82198d7/
  end
  
  it "should have a name" do
    @tag.name.should == 'v0.7.0'
  end
  
  it "should have a type" do
    @tag.type.should eql OBJ_TAG
  end
  
  it "should have an associated Actor" do
    @tag.actor.name.should == 'Tom Preston-Werner'
    @tag.actor.email.should == 'tom@mojombo.com'
  end
  
  it "should have a message" do
    @tag.full_message.should match /xEQAoIUGzPXEp7yZqzSLSXt4mCn1U6rn/
    @tag.short_message.should match /GnuPG v1.4.8/
  end
  
end