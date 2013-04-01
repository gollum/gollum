module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :repo, :jtree
    RJGit.delegate_to(RevTree, :@jtree)
    
    def initialize(repository, mode, path, jtree)
      @repo = repository
      @mode = mode
      @path = path
      @name = File.basename(path)
      @jtree = jtree
      @id = ObjectId.to_string(jtree.get_id)
    end
    
    def data
      strio = StringIO.new
      RJGit::Porcelain.ls_tree(@repo, @jtree, options={:print => true, :io => strio})
      strio.string
    end
    
    def self.find_tree(repository, file_path, branch=Constants::HEAD)
      jrepo = RJGit.repository_type(repository)
      return nil if jrepo.nil?
      last_commit_hash = jrepo.resolve(branch)
      return nil if last_commit_hash.nil?

      walk = RevWalk.new(jrepo)
      commit = walk.parse_commit(last_commit_hash)
      treewalk = TreeWalk.new(jrepo)
      jtree = commit.get_tree
      treewalk.add_tree(jtree)
      treewalk.set_filter(PathFilter.create(file_path))
      if treewalk.next
        jsubtree = walk.lookup_tree(treewalk.object_id(0))
        if jsubtree
          mode = RJGit.get_file_mode(jrepo, file_path, jtree) 
          Tree.new(jrepo, mode, file_path, jsubtree)
        end
      else
        nil
      end
    end
    
  end
  
end