require 'rjgit'
include RJGit

TEST_REPO = File.join(File.dirname(__FILE__), 'fixtures', "dot_git")

  def valid_repo_attributes
    {
      :path => "/tmp/repo_test"
    }
  
  def fixture(name)
    File.read(File.join(File.dirname(__FILE__), 'fixtures', name))
  end

  def create_temp_repo(clone_path)
    filename = TEST_REPO + Time.now.to_i.to_s + rand(300).to_s.rjust(3, '0')
    tmp_path = File.join("/tmp/", filename)
    FileUtils.mkdir_p(tmp_path)
    FileUtils.cp_r(clone_path, tmp_path)
    File.join(tmp_path, 'dot_git')
  end
  
end