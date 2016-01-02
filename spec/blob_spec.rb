require 'spec_helper'

describe Blob do
  
  context "reading blobs" do

    before(:each) do
      @repo = Repo.new(TEST_REPO_PATH)
      @blob = Blob.find_blob(@repo.jrepo, 'materialist.txt')
    end

    it "has an id" do
      expect(@blob.id).to eq 'a423c5f31d193218799b533a6dbdb1052b45505f'
      expect(@blob.get_name).to eq 'a423c5f31d193218799b533a6dbdb1052b45505f'
    end

    it "has a mode" do
      expect(@blob.mode).to eql REG_FILE_TYPE
    end
    
    it "reports symlinks" do
      expect(@blob.is_symlink?).to be false
    end

    it "has a size in bytes" do
      expect(@blob.bytesize).to eql 4680
      expect(@blob.size).to eql 4680
    end
  
    it "returns blob contents" do
      expect(@blob.data).to match /Baudrillardist hyperreality/
    end
    
    it "checks if the blob is binary" do
      expect(@blob).to_not be_binary
    end
    
    it "has a line count" do
      expect(@blob.line_count).to eq 40
    end

    it "returns blame information as an Array" do
      expect(@blob.blame).to be_an Array
      expect(@blob.blame.first[:actor].name).to eq "Dawa Ometto"
    end

    it "prints blame information to IO object" do
      strio = StringIO.new
      @blob.blame({:print => true, :io => strio})
      expect(strio.string).to match /Truth is fundamentally a legal fiction/
    end

    it "returns the correct mime type for known file types" do
      @blob = Blob.find_blob(@repo, 'homer-excited.png')
      expect(@blob.mime_type).to eq 'image/png'
    end

    it "returns text/plain for unknown mime types" do
      expect(Blob.mime_type('abc.argv')).to eq "text/plain"
    end
  
    describe "#find_blob(repository, file_path, branch)" do
      it "returns nil if no blob is found" do
        @blob = Blob.find_blob(@repo, 'abc.argv')
        expect(@blob).to be_nil
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
      expect(@repo.find(blob.id, :blob)).to be_kind_of Blob
      expect(blob.data).to eq string
    end
    
    after(:all) do
      remove_temp_repo(@temp_repo_path)
    end
  end
  
end
