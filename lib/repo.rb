module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  import 'org.eclipse.jgit.storage.file.FileRepository'
  import 'org.eclipse.jgit.treewalk.TreeWalk'
  
  class Repo
  
    attr_accessor :git
    attr_accessor :repo
    attr_accessor :path
    
    TREE_TYPE = 0040000
    SYMLINK_TYPE = 0120000 
    FILE_TYPE = 0100000
    GITLINK_TYPE = 0160000
    MISSING_TYPE = 0000000
    REG_FILE_TYPE = 100644
    
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
      @repo.get_branch
    end
    
    def branches
      return []
    end
    
    def description
      return "blah"
    end
  
    def add(fpattern)
      @git.add(fpattern)
    end
  
    # Convenience method to retrieve a Blob by name
    def blob(name)
      tree_id = @repo.resolve("HEAD^{tree}")
      File.open('/tmp/rjgit.log', 'w') {|f| f.write(tree_id) }
      #puts "tree_id: " + tree_id unless tree_id.nil?
      return nil if tree_id.nil?
      walk = TreeWalk.new(@repo)
      walk.addTree(tree_id)
      walk.setRecursive(true)
       
      while (walk.next())
        mode = walk.getFileMode(0)
        if mode.equals(REG_FILE_TYPE)
          if name == walk.getNameString()
            File.open('/tmp/rjgit.log', 'a') {|f| f.write("Yay! #{name}") }
          end
        end
      end
      
    end
  
    # Convenience method to retrieve a Tree by name
    def tree(name)
    end
    
  end

end