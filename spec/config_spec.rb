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
  
  it "should respond to Hash syntax" do
    @config.data['[core]'].should be_a Hash
    @config.data['[rspec]'] = {:test => 'rspec'}
    @config.data['[rspec]'][:test].should == 'rspec'
  end
  
  it "should return all sections as keys" do
    @config.sections.should have(3).sections
    @config.sections.first.should == '[core]'
  end
  
  it "should fetch values for keys" do
    @config.fetch('[core]').should_not be_nil
  end
  
  it "should fetch a default when no value is set" do
    @config.fetch('[rspec]', {}).should be_a Hash
    @config.fetch('[rspec]', {}).should be_empty
  end
  
  it "should raise IndexError when no value can be fetched" do
    expect { @config.fetch('[rspec]') }.to raise_error(IndexError)
  end
  
  it "should read in a local config file"
  
end