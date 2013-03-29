module RJGit

  import 'org.eclipse.jgit.lib.Config'
  
  class Configuration
    
    attr_reader :jconfig, :path
    
    def initialize(path)
      @path = path
      @jconfig = org.eclipse.jgit.lib.Config.new
    end
    
    def load
      begin
        @jconfig.from_text(IO.read(@path))
      rescue => e
        
      end
    end
    
  end # Config
end