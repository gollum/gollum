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
  
  # gem requires
  require 'mime/types'
  # require helpers first because RJGit#delegate_to is needed
  require "#{File.dirname(__FILE__)}/rjgit_helpers.rb"
  # require everything else
  begin
    Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file| 
      require file
    end
  end
  
  import 'org.eclipse.jgit.lib.ObjectId'
   
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
    
    def self.ls_tree(repository, branch=Constants::HEAD, options = {:recursive => false, :print => false})
      
      last_commit_hash = repository.resolve(branch)
      return nil unless last_commit_hash

      walk = RevWalk.new(repository)
      commit = walk.parse_commit(last_commit_hash)
      revtree = commit.getTree
      treewalk = TreeWalk.new(repository)
      treewalk.set_recursive(options[:recursive])
      treewalk.add_tree(revtree)
      entries = []
      while treewalk.next
        entry = {}
        mode = treewalk.getFileMode(0)
        entry[:mode] = mode.to_string.to_i
        entry[:type] = Constants.typeString(mode.getObjectType)
        entry[:id]   = treewalk.getObjectId(0).name
        entry[:path] = treewalk.getPathString
        entries << entry
      end
      print(entries) if options[:print]
      entries
    end
    
  end
  
  def print(entries)
    entries.each do |entry|
      $stdout.print entry[:mode]
      $stdout.print "\t"
      $stdout.print entry[:type]
      $stdout.print "\t"
      $stdout.print entry[:id]
      $stdout.print "\t"
      $stdout.print entry[:path]
      $stdout.puts
    end
  end
  
end


