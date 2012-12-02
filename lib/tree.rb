module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :repo, :revtree
    RJGit.delegate_to(RevTree, :@revtree)
    
    def initialize(repository, mode, path, revtree)
      @repo = repository
      @mode = mode
      @path = path
      @name = File.basename(path)
      @revtree = revtree
      @id = ObjectId.to_string(revtree.get_id)
    end
    
    def data
      strio = StringIO.new
      RJGit::Porcelain.ls_tree(@repo, @revtree, Constants::HEAD, options={:print => true, :io => strio})
      strio.string
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
          Tree.new(repository, mode, file_path, tree)
        end
      else
        nil
      end
    end
    
  end
  
end