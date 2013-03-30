require 'spec_helper'

  import 'org.eclipse.jgit.errors.ConfigInvalidException'
  
describe RJGit::Configuration do
  
  context "with a fairly standard config file" do
    before(:each) do
      config_path = File.join(TEST_BARE_REPO_PATH, 'config')
      @config = RJGit::Configuration.new(config_path)
      @config.load
    end
  
    it "should correctly parse a standard config file" do
      @config.to_s.should_not be_nil
      @config.names('remote', 'origin').first.should == 'fetch'
    end
  
    it "should raise an error when the config file is invalid" do
      @config = RJGit::Configuration.new(File.join(FIXTURES_PATH, 'nested_groups_config.cfg'))
      expect { @config.load }.to raise_error(IOException)
    end
  
    it "should have sections" do
      @config.sections.should have(3).sections
      @config.sections.first.should == 'core'
    end
    
    it "should have subsections" do
      @config.subsections('remote').first.should == 'origin'
    end
    
    it "should have settings" do
      @config['remote origin']['url'].should == "git@github.com:schacon/grit.git"
    end
    
    it "should respond to Hash syntax" do
      $stderr.puts @config['core']
      @config['core'].should be_a Hash
    end
    
    it "should not load the config twice" do
      @config.sections.should have(3).sections
      @config.load
      @config.sections.should have(3).sections
    end
  
    it "should set loaded variable to true" do
      @config.loaded?.should be_true
    end
  
    it "should return nil if no value is set" do
      @config['core']['rspec'].should be_a NilClass
    end
  
    it "should add a new setting" do
      @config.add_setting('rspec', 'true', 'rspec-section', 'rspec-subsection')
      @config.sections.should include('rspec-section')
      @config.names('rspec-section', 'rspec-subsection').first.should == 'rspec'
    end
    
  end 
    
end