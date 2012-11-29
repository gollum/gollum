require 'logger'

module RJGit

  begin
    require 'java'
    Dir["#{File.dirname(__FILE__)}/java/jars/*.jar"].each { |jar| require jar }
  rescue LoadError
    puts "You need to be running JRuby to use this gem."
    raise
  end

  @logger ||= ::Logger.new(STDOUT)
  
  def self.version
    VERSION
  end
  
  # internal requires
  
  # require helpers first because RJGit#delegate_to is needed
  require "#{File.dirname(__FILE__)}/rjgit_helpers.rb"
  # require everything else
  begin
    Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file| 
      require file
    end
  end
  
   
  class Porcelain
    
    import 'org.eclipse.jgit.api.AddCommand'
    import 'org.eclipse.jgit.api.CommitCommand'
    
    # http://wiki.eclipse.org/JGit/User_Guide#Porcelain_API
    def self.add(repository, file_pattern)
      git = repository.git.git
      add_command = git.add
      add_command.addFilepattern(file_pattern).call
    end
    
    def self.commit(repository, message="")
      git = repository.git.git
      commit_command = git.commit
      commit_command.setMessage(message).call
    end
    
    # http://dev.eclipse.org/mhonarc/lists/jgit-dev/msg00558.html
    def self.cat_file(repository, object)
      bytes = repository.open(object.id).get_bytes
      return bytes.to_a.pack('c*').force_encoding('UTF-8')
    end
    
    def self.ls_tree
      
    end
    
  end
  
end


