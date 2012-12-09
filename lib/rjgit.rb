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
      git = repository.git.git
      add_command = git.add
      add_command.add_file_pattern(file_pattern).call
    end
    
    def self.commit(repository, message="")
      git = repository.git.git
      commit_command = git.commit
      commit_command.set_message(message).call
    end
    
    # http://dev.eclipse.org/mhonarc/lists/jgit-dev/msg00558.html
    def self.cat_file(repository, object)
      bytes = repository.open(object.id).get_bytes
      return bytes.to_a.pack('c*').force_encoding('UTF-8')
    end
    
    def self.ls_tree(repository, tree=nil, branch=Constants::HEAD, options={})
      options = {:recursive => false, :print => false, :io => $stdout}.merge(options)
      repository = repository_type(repository)
      if tree 
        revtree = tree_type(tree)
      else
        last_commit_hash = repository.resolve(branch)
        return nil unless last_commit_hash
        walk = RevWalk.new(repository)
        commit = walk.parse_commit(last_commit_hash)
        revtree = commit.get_tree
      end
      treewalk = TreeWalk.new(repository)
      treewalk.set_recursive(options[:recursive])
      treewalk.add_tree(revtree)
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
      repo = repository_type(repository)
      return nil unless repo

      blame_command = BlameCommand.new(repo)
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
    
    def self.diff(repository, old_tree=nil, new_tree=nil, file_path=nil, options = {})
      options = {:namestatus => false}.merge(options)
      git = repository.git.jgit
      diff_command = git.diff
      diff_command.set_old_tree(old_tree) if old_tree
      diff_command.set_new_tree(new_tree) if new_tree
      diff_command.set_path_filter(PathFilter.create(file_path)) if file_path
      diff_command.set_show_name_and_status_only(true) if options[:namestatus] 
      diff_entries = diff_command.call
      diff_entries = diff_entries.to_array.to_ary
      diff_entries = convert_diff_entries(diff_entries)
      diff_entries
    end
    
  end
  
end


