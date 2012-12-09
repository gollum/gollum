require 'spec_helper'

# Useful command git ls-tree HEAD

describe RJGit do
  before(:all) do
    @bare_repo = Repo.new(TEST_BARE_REPO_PATH)
    @git = RubyGit.new(@bare_repo.jrepo)
  end
  
  it "should have a version" do
    RJGit.version.should equal RJGit::VERSION
  end
  
  context "delegating missing methods to the underlying jgit Git object" do
     it "should delegate the method to the JGit object" do
       @git.send(:rebase).should be_a org.eclipse.jgit.api.RebaseCommand # :rebase method not implemented in RubyGit, but is implemented in the underlying JGit object
     end
     
     it "should throw an exception if the JGit object does not know the method" do
       expect { @git.send(:non_existent_method) }.to raise_error(NoMethodError)
     end
  end
  
  describe Porcelain do
    it "should mimic git-cat-file" do
      blob = @bare_repo.blob('lib/grit.rb')
      RJGit::Porcelain.cat_file(@bare_repo, blob.jblob).should =~ /# core\n/
    end
    
    it "should mimic git-ls-tree" do
      listing = RJGit::Porcelain.ls_tree(@bare_repo.jrepo)
      listing.should be_an Array
      first_entry = listing.first
      first_entry.should be_a Hash
      first_entry[:mode].should == REG_FILE_TYPE
      first_entry[:type].should == 'blob'
      first_entry[:id].should match /baaa47163a922b716898936f4ab032db4e08ae8a/
      first_entry[:path].should == '.gitignore'
    end
    
    it "should mimic git-blame" do
      RJGit::Porcelain.blame(@bare_repo, 'lib/grit.rb')
    end
    
 context "producing diffs" do
      before(:each) do
        @tmp_repo_path = create_temp_repo(TEST_REPO_PATH)
        @repo = Repo.new(@tmp_repo_path)
        File.open("#{@tmp_repo_path}/rspec-addfile.txt", 'w') {|file| file.write("This is a new file to add.") }
        @repo.add("rspec-addfile.txt")
      end
      
      it "should return diff information of working tree when adding file" do
        entry = RJGit::Porcelain.diff(@repo, {:cached => true}).first
        entry.should be_a Hash
        entry[:changetype].should == "ADD"
        entry[:newid].should match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.commit("Committing a test file to a test repository.")
        RJGit::Porcelain.diff(@repo).should == []
      end
      
      it "should return diff information of working tree when removing file" do 
        @repo.commit("Adding rspec-addfile.txt so it can be deleted.")
        @repo.remove("rspec-addfile.txt")
        entry = RJGit::Porcelain.diff(@repo, {:cached => true}).first
        entry[:changetype].should == "DELETE"
        entry[:oldpath].should == "rspec-addfile.txt"
        @repo.commit("Removing test file.")
        RJGit::Porcelain.diff(@repo).should == []
      end
      
      after(:each) do
        @repo = nil
	      remove_temp_repo(@tmp_repo_path)
      end 
    end  
  end # end Porcelain
  
  describe "helper methods" do
    specify {RJGit.repository_type("A String").should be_nil}
    specify {RJGit.tree_type("A String").should be_nil}
    specify {RJGit.underscore("CamelCaseToSnakeCase").should == 'camel_case_to_snake_case'}
  end
  
  after(:all) do
    @bare_repo = nil
  end
end