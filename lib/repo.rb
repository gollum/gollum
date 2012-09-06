module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  
  class Repo
  
    attr_accessor :git
    attr_accessor :repo
    attr_accessor :path
    attr_accessor :working_dir
    attr_reader :bare
    
    def initialize(path, options = {}, create = false)
      epath = File.expand_path(path)

      if File.exist?(File.join(epath, '/.git'))
        @bare = false
      elsif File.exist?(epath) || options[:bare]
        @bare = true
      end
      
      @path = @bare ? epath : File.join(epath, '/.git')
      @working_dir = epath unless @bare
      
      repo_path = java.io.File.new(@path)
      @repo = RepositoryBuilder.new().set_git_dir(repo_path).build()
      @repo.create if create
      @git = RubyGit.new(@repo)
      
    end
  
    def bare?
      @bare
    end
    
    def self.create(path, options = {:bare => true})
      Repo.new(path, options, true)
    end
  
    def commits(ref="master", limit=100)
      options = { :limit => limit }
      Commit.find_all(@repo, ref, options)
    end
  
    def branch
      @repo.get_branch
    end
    
    def description
    end
  
  end

end