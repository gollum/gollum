module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  import 'org.eclipse.jgit.storage.file.FileRepository'
  import 'org.eclipse.jgit.treewalk.TreeWalk'
  import 'org.eclipse.jgit.treewalk.filter.PathFilter'
  import 'org.eclipse.jgit.lib.Constants'

  
  class Repo
    
    attr_accessor :git
    attr_accessor :repo
    attr_accessor :path

    RJGit.delegate_to(Repository, :@repo)
    
    def initialize(path, options = {}, create = false)
      epath = File.expand_path(path)

      bare = false
      if File.exist?(File.join(epath, '/.git'))
        bare = false
      elsif File.exist?(epath) || options[:bare]
        bare = true
      end

      @path = bare ? epath : File.join(epath, '/.git')

      repo_path = java.io.File.new(@path)
      @repo = bare ? RepositoryBuilder.new().set_bare.set_git_dir(repo_path).build() : RepositoryBuilder.new().set_git_dir(repo_path).build()
      @repo.create(bare) if create
      @git = RubyGit.new(@repo)
    end
    
    def bare?
      @repo.is_bare
    end

    def self.create(path, options = {:bare => true})
      Repo.new(path, options, true)
    end

    def commits(ref="master", limit=100)
      options = { :limit => limit }
      Commit.find_all(@repo, ref, options)
    end

    def branch
      @repo.get_full_branch
    end

    def branches
      return @git.branch_list
    end

    def add(fpattern)
      @git.add(fpattern)
    end

    # Convenience method to retrieve a Blob by name
    def blob(file_path)
      Blob.find_blob(@repo, file_path)
    end

    # Convenience method to retrieve a Tree by name
    def tree(file_path)
      Tree.find_tree(@repo, file_path)
    end

  end

end
