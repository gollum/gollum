require 'spec_helper'

describe Blob do
  
  context "reading blobs" do

    before(:each) do
      @repo = Repo.new(TEST_REPO_PATH)
      @blob = Blob.find_blob(@repo.jrepo, 'materialist.txt')
    end

    it "should have a mode" do
      @blob.mode.should eql REG_FILE_TYPE
    end
    
    it "should report symlinks" do
      @blob.is_symlink?.should be_false
    end

    it "should have a size in bytes" do
      @blob.bytesize.should eql 4680
      @blob.size.should eql 4680
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
      @blob = Blob.find_blob(@repo, 'homer-excited.png')
      @blob.mime_type.should == 'image/png'
    end

    it "should return text/plain for unknown mime types" do
      Blob.mime_type('abc.argv').should == "text/plain"
    end
  
    describe "#find_blob(repository, file_path, branch)" do
      it "should return nil if no blob is found" do
        @blob = Blob.find_blob(@repo, 'abc.argv')
        @blob.should be_nil
      end
    end

    after(:each) do
      @repo = nil
    end
  
  end
  
  context "creating blobs" do
    before(:all) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end
    
    it "creates blobs from a string" do
      string = "My string"
      blob = Blob.new_from_string(@repo, string)
      @repo.find(blob.id, :blob).should be_kind_of Blob
      blob.data.should == string
    end
    
    after(:all) do
      remove_temp_repo(@temp_repo_path)
    end
  end
  
end
