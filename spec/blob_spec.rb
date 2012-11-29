require 'spec_helper'

describe Blob do

  before(:all) do
    @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
    @repo = Repo.new(@temp_repo_path)
    @blob = Blob.find_blob(@repo.repo, 'materialist.txt')
  end

  it "should have a mode"

  it "should have a size in bytes"   
  
  it "should return blob contents" do
    @blob.data.should match /Baudrillardist hyperreality/
  end

  it "should return file size" do
    pending
    # Git.any_instance.expects(:cat_file).returns(fixture('cat_file_blob_size'))
    # blob = Blob.create(@repo, :id => 'abc')
    # blob.size.should == 11
  end

  it "should return blame information"

  # mime_type

  it "should return the correct mime type for known file types" do
    # blob = Blob.create(@repo, :id => 'abc', :name => 'foo.png')
    # blob.mime_type.should == "image/png"
    pending
  end

  it "should return text/plain for unknown mime types" do
    # blob = Blob.create(@repo, :id => 'abc')
    # blob.mime_type.should == "text/plain"
    pending
  end

  after(:all) do
    remove_temp_repo(File.dirname(@temp_repo_path))
    nil
  end
end
