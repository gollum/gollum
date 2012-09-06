module RJGit

  import 'org.eclipse.jgit.api.Git'

  class RubyGit
  
    attr_accessor :git
    attr_accessor :repo
  
    def initialize(repository)
      @repo = repository
      @git = Git.new(repository)
    end
  
    def log
      logs = @git.log
      commits = Array.new
      logs.call.each do |commit|
        commits << Commit.new(commit)
      end
      commits
    end
  
    def branch_list
      branch = @git.branch_list
      array = Array.new
      branch.call.each do |b|
        array << b.get_name
      end
      array
    end
  
  end

end