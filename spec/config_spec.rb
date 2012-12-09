require 'spec_helper'

describe RJGit::Config do
  
  before(:each) do
    config_path = File.join(TEST_BARE_REPO_PATH, 'config')
    @config = RJGit::Config.new(config_path)
  end
  
  it "should read in any config file" do
    @config.data.should be_a Hash
    @config['[core]']['repositoryformatversion'].should == '0'
  end
  
  it "should read in a local config file"
  
end