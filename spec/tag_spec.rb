require 'spec_helper'

describe Tag do
  before(:each) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH, is_bare: true, create: false)
    @tag = @bare_repo.tags['v0.7.0']
  end
  
  it "has an id" do
    expect(@tag.id).to match /f0055fda16c18fd8b27986dbf038c735b82198d7/
    expect(@tag.get_name).to match /f0055fda16c18fd8b27986dbf038c735b82198d7/
  end
  
  it "has a name" do
    expect(@tag.name).to eq 'v0.7.0'
  end
  
  it "has a type" do
    expect(@tag.type).to eql OBJ_TAG
  end
  
  it "has an associated Actor" do
    expect(@tag.actor.name).to eq 'Tom Preston-Werner'
    expect(@tag.actor.email).to eq 'tom@mojombo.com'
  end
  
  it "has a message" do
    expect(@tag.full_message).to match /xEQAoIUGzPXEp7yZqzSLSXt4mCn1U6rn/
    expect(@tag.short_message).to match /GnuPG v1.4.8/
  end
  
end