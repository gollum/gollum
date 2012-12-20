module RJGit

  begin
    require 'java'
    Dir["#{File.dirname(__FILE__)}/java/jars/*.jar"].each { |jar| require jar }
  rescue LoadError
    puts "You need to be running JRuby to use this gem."
    raise
  end

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
    import 'org.eclipse.jgit.api.BlameCommand'
    import 'org.eclipse.jgit.blame.BlameGenerator'
    import 'org.eclipse.jgit.blame.BlameResult'
    
    # http://wiki.eclipse.org/JGit/User_Guide#Porcelain_API
    def self.add(repository, file_pattern)
      repository.add(file_pattern)
    end
    
    def self.commit(repository, message="")
      repository.commit(message)
    end
    
    # http://dev.eclipse.org/mhonarc/lists/jgit-dev/msg00558.html
    def self.cat_file(repository, object)
      bytes = repository.open(object.id).get_bytes
      return bytes.to_a.pack('c*').force_encoding('UTF-8')
    end
    
    def self.ls_tree(repository, tree=nil, branch=Constants::HEAD, options={})
      options = {:recursive => false, :print => false, :io => $stdout}.merge(options)
      jrepo = RJGit.repository_type(repository)
      return nil unless jrepo
      if tree 
        jtree = RJGit.tree_type(tree)
      else
        last_commit_hash = jrepo.resolve(branch)
        return nil unless last_commit_hash
        walk = RevWalk.new(jrepo)
        jcommit = walk.parse_commit(last_commit_hash)
        jtree = jcommit.get_tree
      end
      treewalk = TreeWalk.new(jrepo)
      treewalk.set_recursive(options[:recursive])
      treewalk.add_tree(jtree)
      entries = []
      while treewalk.next
        entry = {}
        mode = treewalk.get_file_mode(0)
        entry[:mode] = mode.get_bits
        entry[:type] = Constants.type_string(mode.get_object_type)
        entry[:id]   = treewalk.get_object_id(0).name
        entry[:path] = treewalk.get_path_string
        entries << entry
      end
      options[:io].puts RJGit.stringify(entries) if options[:print]
      entries
    end
      
    def self.blame(repository, file_path, options={})
      options = {:print => false, :io => $stdout}.merge(options)
      jrepo = RJGit.repository_type(repository)
      return nil unless jrepo

      blame_command = BlameCommand.new(jrepo)
      blame_command.set_file_path(file_path)
      result = blame_command.call
      content = result.get_result_contents
      blame = []
      for index in (0..content.size - 1) do
        blameline = {}
        blameline[:actor] = Actor.new(result.get_source_author(index))
        blameline[:line] = result.get_source_line(index)
        blameline[:commit] = Commit.new(result.get_source_commit(index))
        blameline[:line] = content.get_string(index)
        blame << blameline
      end
      options[:io].puts RJGit.stringify(blame) if options[:print]
      return blame
    end
    
    def self.diff(repository, options = {})
      options = {:namestatus => false}.merge(options)
      git = repository.git.jgit
      diff_command = git.diff
      diff_command.set_old_tree(old_tree) if options[:old_tree]
      diff_command.set_new_tree(new_tree) if options[:new_tree]
      diff_command.set_path_filter(PathFilter.create(file_path)) if options[:file_path]
      diff_command.set_show_name_and_status_only(true) if options[:namestatus] 
      diff_command.set_cached(true) if options[:cached]
      diff_entries = diff_command.call
      diff_entries = diff_entries.to_array.to_ary
      diff_entries = RJGit.convert_diff_entries(diff_entries)
      diff_entries
    end
    
  end
  
end


