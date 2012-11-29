module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :revtree
    RJGit.delegate_to(RevTree, :@revtree)
    
    def initialize(revtree)
      @revtree = revtree
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
    
  end
  
end