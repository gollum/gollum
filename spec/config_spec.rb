require 'spec_helper'

describe RJGit::Config do
  
  context "with a fairly standard config file" do
    before(:each) do
      config_path = File.join(TEST_BARE_REPO_PATH, 'config')
      @config = RJGit::Config.new(config_path)
      @config.load
    end
  
    it "should correctly parse a standard config file" do
      @config.groups.should have(3).groups
      @config.groups.first.should have(4).settings
    end
  
    it "should not load the config twice" do
      @config.groups.should have(3).groups
      @config.groups.first.should have(4).settings
    end
  
    it "should respond to Hash syntax" do
      @config['core'].should be_a RJGit::Config::Group
      @config['core'].settings.first.key.should == 'repositoryformatversion'
    end
  
    it "should return all top-level sections" do
      @config.sections.should have(3).sections
      @config.sections.first.should == 'core'
    end
  
    it "should fetch values of settings in a group" do
      @config['core'].fetch('filemode').should be_true
    end
  
    it "should fetch a default when no value is set" do
      @config['core'].fetch('rspec', {}).should be_a Hash
      @config['core'].fetch('rspec', {}).should be_empty
    end
  
    it "should raise IndexError when no value can be fetched" do
      expect { @config['core'].fetch('rspec') }.to raise_error(IndexError)
    end
  
    it "should add a new group" do
      @config.add_group('github')
      @config['github'].should be_a RJGit::Config::Group
    end
  
    it "should add a new setting" do
      @config.add_setting('rspec', 'true', 'Currently using Rspec')
      @config.settings.first.key.should == 'rspec'
    end
    
    describe RJGit::Config::Group do
      before(:each) do
        @group = @config['core']
      end
      
      it "should add a comment" do
        @group.add_comment("These are the core configuration options")
        @group.comments.join.should match /^(\#|;)/
      end
      
      it "should add a setting" do
        @group.add_setting('rspec', 'true', 'Adding a setting to a specific group')
        @group['rspec'].comments.join.should match /^(\#|;)/
      end 
    end
  end  
  
  context "with a complex config file with comments and nested groups" do 
    before(:each) do
      @config = RJGit::Config.new(File.join(FIXTURES_PATH, 'nested_groups_config.cfg')).load
    end
    
    it "should preserve comments" do
      @config['core'].comments.first.should match /# This is the first core group/ 
    end
    
    it "should preserve in-line comments" do
      @config['fourth'].group('core').settings[1].comments.first.should match /; for the rest/
    end
    
    it "should correctly parse a config file with nested groups" do
      @config['third'].groups.first.name.should == 'nested'
    end
    
    it "should find groups and subgroups based on a a regexp expression" do
      @config.find_groups(/nested/).should have(3).groups
    end
    
    it "should have all groups" do
      @config.groups.should have(5).groups
      @config.all_groups.should have(10).groups
    end
    
    it "should store the config to file" do
      path = File.join(get_new_tmprepo_path, 'temp_config')
      Dir.mkdir(File.dirname(path))
      @config.store(path)
      path.should exist
      IO.readlines(path).first.should match /general setting/
      remove_temp_repo(File.dirname(path))
    end
    
    it "should reload the config file" do
      path = File.join(get_new_tmprepo_path, 'temp_config')
      Dir.mkdir(File.dirname(path))
      @config.store(path)
      config = RJGit::Config.new(path).load
      config.should have(5).groups
      File.open(path, "a") {|cfg| cfg.write "[ rspec ]\n rspec = true" }
      config.reload!
      config.should have(6).groups
      config['rspec']['rspec'].value.should == 'true'
      remove_temp_repo(File.dirname(path))
    end
    
  end
    
end