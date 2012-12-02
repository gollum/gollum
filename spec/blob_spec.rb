require 'spec_helper'

describe Blob do

  before(:each) do
    @repo = Repo.new(TEST_REPO_PATH)
    @blob = Blob.find_blob(@repo.repo, 'materialist.txt')
  end

  it "should have a mode" do
    @blob.mode.should eql REG_FILE_TYPE
  end

  it "should have a size in bytes" do
    @blob.bytesize.should eql 4680
  end
  
  it "should return blob contents" do
    @blob.data.should match /Baudrillardist hyperreality/
  end

  it "should return blame information as an Array" do
    @blob.blame.should be_an Array
    @blob.blame.first[:actor].name.should == "Dawa Ometto"
  end

  it "should print blame information to IO object" do
    strio = StringIO.new
    @blob.blame({:print => true, :io => strio})
    strio.string.should match /Truth is fundamentally a legal fiction/
  end

  it "should return the correct mime type for known file types" do
    @blob = Blob.find_blob(@repo.repo, 'homer-excited.png')
    @blob.mime_type.should == 'image/png'
  end

  it "should return text/plain for unknown mime types" do
    Blob.mime_type('abc.argv').should == "text/plain"
  end

  after(:each) do
    @repo = nil
  end
end
