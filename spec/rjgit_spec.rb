require 'spec_helper'

# Useful command git ls-tree HEAD

describe RJGit do
  before(:all) do
    @temp_bare_repo_path = create_temp_repo(TEST_BARE_REPO_PATH)
    @bare_repo = Repo.new(@temp_bare_repo_path)
    @git = RubyGit.new(@bare_repo.repo)
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
      RJGit::Porcelain.cat_file(@bare_repo, blob.blob).should =~ /# core\n/
    end
    
    it "should mimic git-ls-tree" do
      listing = RJGit::Porcelain.ls_tree(@bare_repo.repo)
      listing.should be_an Array
      first_entry = listing.first
      first_entry.should be_a Hash
      first_entry[:mode].should == REG_FILE_TYPE
      first_entry[:type].should == 'blob'
      first_entry[:id].should match /baaa47163a922b716898936f4ab032db4e08ae8a/
      first_entry[:path].should == '.gitignore'
    end
    
  end
  
  after(:all) do
    remove_temp_repo(File.dirname(@temp_bare_repo_path))
  end
end