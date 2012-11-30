require 'spec_helper'

describe Blob do

  before(:all) do
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
    @blob = Blob.find_blob(@repo.repo, 'materialist.txt')
  end

  it "should have a mode" do
    @blob.mode.should eql 100644
  end

  it "should have a size in bytes" do
    @blob.bytesize.should eql 4680
  end
  
  it "should return blob contents" do
    @blob.data.should match /Baudrillardist hyperreality/
  end

  it "should return blame information"

  # mime_type

  it "should return the correct mime type for known file types" do
    @blob = Blob.find_blob(@repo.repo, 'homer-excited.png')
    @blob.mime_type.should == 'image/png'
  end

  it "should return text/plain for unknown mime types" do
    Blob.mime_type('abc.argv').should == "text/plain"
  end

  after(:all) do
    remove_temp_repo(File.dirname(@temp_repo_path))
    nil
  end
end
