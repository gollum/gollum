require 'spec_helper'

describe RubyGit do
  
  it "should return log information"
  
  it "should tag with commit or revision id"
  
  it "should tag without commit or revision id"
  
  it "should clone repositories"
  
  it "should apply a patch to a file"
  
  context "cleaning a repository" do
    before(:each) do
      @tmp_repo_path = get_new_tmprepo_path
      @repo = Repo.create(@tmp_repo_path)
  	  File.open(File.join(@tmp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
    end
    
    it "should remove untracked files from the working tree" do
      @repo.clean
      File.exist?(File.join(@tmp_repo_path, "rspec-addfile.txt")).should be_false
    end
    
    context "after adding files" do
      
      before(:each) do
        @repo.add("#{@tmp_repo_path}/rspec-addfile.txt")
        @entry = RJGit::Porcelain.diff(@repo).first
      end
      it "should remove added files from the index" do
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean
        @entry = RJGit::Porcelain.diff(@repo).first
        @entry.should be_nil
      end
    
      it "should perform a dry run when asked" do
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean(:dryrun => true)
        @entry = RJGit::Porcelain.diff(@repo).first
        @entry[:changetype].should == "ADD"
        @entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
      end
    end
    
    after(:each) do
      @repo = nil
      remove_temp_repo(@tmp_repo_path)
    end
  end
  
end


