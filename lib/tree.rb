module RJGit
  
  class Tree

    attr_reader :contents
    attr_reader :id
    attr_reader :mode
    attr_reader :name
    
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