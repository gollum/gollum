module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :revtree
    RJGit.delegate_to(RevTree, :@revtree)
    
    def initialize(mode, name, revtree)
      @mode = mode
      @name = name
      @revtree = revtree
      @id = ObjectId.toString(revtree.get_id)
    end
    
    
    def self.construct(repo, treeish, paths = [])
    end
    
    def construct_initialize(repo, id, text)
    end
    
    def self.create(repo, atts)
    end
    
    def basename
      File.basename(name)
    end
    
    def self.find_tree(repository, file_path, branch=Constants::HEAD)
      last_commit_hash = repository.resolve(branch)
      return nil if last_commit_hash.nil?

      walk = RevWalk.new(repository)
      commit = walk.parse_commit(last_commit_hash)
      treewalk = TreeWalk.new(repository)
      revtree = commit.get_tree
      treewalk.add_tree(revtree)
      treewalk.set_filter(PathFilter.create(file_path))
      if treewalk.next
        tree = walk.lookup_tree(treewalk.object_id(0))
        if tree
          mode = RJGit.get_file_mode(repository, file_path, revtree) 
          Tree.new(mode, file_path, tree)
        end
      else
        nil
      end
    end
    
  end
  
end