require 'simplecov'

SimpleCov.start

require 'rjgit'
include RJGit

TEST_REPO_NAME = "dot_git"
TEST_REPO_PATH = File.join(File.dirname(__FILE__), 'fixtures', TEST_REPO_NAME)
TEST_BARE_REPO_NAME = "dot_bare_git"
TEST_BARE_REPO_PATH = File.join(File.dirname(__FILE__), 'fixtures', TEST_BARE_REPO_NAME)


def valid_repo_attributes
  {
    :path => "/tmp/repo_test"
  }
end

def fixture(name)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', name))
end

def create_temp_repo(clone_path)
  filename = 'git_test' + Time.now.to_i.to_s + rand(300).to_s.rjust(3, '0')
  tmp_path = File.join("/tmp/", filename)
  FileUtils.mkdir_p(tmp_path)
  FileUtils.cp_r(clone_path, tmp_path)
  File.join(tmp_path, File.basename(clone_path))
end

def remove_temp_repo(path)
  FileUtils.remove_dir(path) if File.exists?(path)
end

# Require any custom RSpec matchers
Dir[File.dirname(__FILE__) + "/support/matchers/*.rb"].each {|f| require f}