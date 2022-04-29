require 'spec_helper'

  java_import 'org.eclipse.jgit.errors.ConfigInvalidException'
  
describe RJGit::Configuration do
  
  context "with a fairly standard config file" do
    before(:each) do
      config_path = File.join(TEST_BARE_REPO_PATH, 'config')
      @config = RJGit::Configuration.new(config_path)
      @config.load
    end
  
    it "correctly parses a standard config file" do
      expect(@config.to_s).to_not be_nil
      expect(@config.names('remote', 'origin').first).to eq 'fetch'
    end
  
    it "raises an error when the config file is invalid" do
      @config = RJGit::Configuration.new(File.join(FIXTURES_PATH, 'nested_groups_config.cfg'))
      expect { @config.load }.to raise_error(IOException)
    end
  
    it "has sections" do
      expect(@config.sections).to have(3).sections
      expect(@config.sections.first).to eq 'core'
    end
    
    it "has subsections" do
      expect(@config.subsections('remote').first).to eq 'origin'
    end
    
    it "has settings" do
      expect(@config['remote origin']['url']).to eq "git@github.com:schacon/grit.git"
    end
    
    it "responds to Hash syntax" do
      expect(@config['core']).to be_a Hash
      expect(@config['core']['bare']).to be false
    end
    
    it "does not load the config twice" do
      expect(@config.sections).to have(3).sections
      @config.load
      expect(@config.sections).to have(3).sections
    end
  
    it "sets loaded variable to true" do
      expect(@config).to be_loaded
    end
  
    it "returns nil if no value is set" do
      expect(@config['core']['rspec']).to be_a NilClass
    end
  
    it "adds a new boolean setting" do
      @config.add_setting('rspec', true, 'rspec-section', 'rspec-subsection')
      expect(@config.sections).to include('rspec-section')
      expect(@config.names('rspec-section', 'rspec-subsection').first).to eq 'rspec'
    end

    it "adds a new String setting" do
      @config.add_setting('rspec', 'enabled', 'rspec-section', 'rspec-subsection')
      expect(@config.sections).to include('rspec-section')
      expect(@config.names('rspec-section', 'rspec-subsection').first).to eq 'rspec'
    end
    
    it "adds a new numeric setting" do
      @config.add_setting('rspec', 42, 'rspec-section', 'rspec-subsection')
      expect(@config.sections).to include('rspec-section')
      expect(@config['rspec-section rspec-subsection']['rspec']).to eql 42
    end
    
    it "fails to add any other type of setting" do
      @config.add_setting('rspec', nil, 'rspec-section', 'rspec-subsection')
      expect(@config.sections).to_not include('rspec-section')
    end
    
  end 
    
end