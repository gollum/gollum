require 'spec_helper'

describe Config do
  
  before(:each) do
    config_path = File.join(TEST_BARE_REPO_PATH, config)
    @conf = RJGit::Config.new
    @conf.load_config(config_path)
    $stderr.puts @conf
  end
  
  it "should read in any config file" do
    #$stderr.puts @conf
  end
  
  it "should read in a local config file"
  
end