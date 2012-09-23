module RJGit

  import 'org.eclipse.jgit.lib.ObjectId'
  
  class Ref

    def initialize(javaRef)
    	@ref = javaRef
    end
    
  end

end