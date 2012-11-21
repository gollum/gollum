module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  require 'delegate'
  
  class Tree < Delegator

    attr_reader :contents
    attr_reader :id
    attr_reader :mode
    attr_reader :name
    attr_reader :revtree
    
    def initialize(revtree)
      @revtree = revtree
    end
    
    def __getobj__ ; @revtree ; end    
    def __setobj__(obj) ; @revtree = obj ; end
    
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