module RJGit

  begin
    require 'java'
    Dir["#{File.dirname(__FILE__)}/java/jars/*.jar"].each { |jar| require jar }
  rescue LoadError
    raise "You need to be running JRuby to use this gem."
  end

  def self.version
    VERSION
  end
  
  require 'stringio'
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
   
  module Porcelain
   
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
    
    def self.ls_tree(repository, tree=nil, options={})
      options = {:recursive => false, :print => false, :io => $stdout, :branch => Constants::HEAD}.merge(options)
      jrepo = RJGit.repository_type(repository)
      return nil unless jrepo
      if tree 
        jtree = RJGit.tree_type(tree)
      else
        last_commit_hash = jrepo.resolve(options[:branch])
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
      return entries
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
        blameline[:actor] = Actor.new_from_person_ident(result.get_source_author(index))
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
      return diff_entries
    end
    
  end
  
  module Plumbing
    import org.eclipse.jgit.lib.Constants
    
    class TreeBuilder
      import org.eclipse.jgit.lib.FileMode
      import org.eclipse.jgit.lib.TreeFormatter
      
    
      attr_accessor :treemap
      attr_reader :object_inserter, :log
      
      def initialize(repository)
        @jrepo = RJGit.repository_type(repository)
        @object_inserter = @jrepo.newObjectInserter
        @treemap = {}
        init_log
      end
      
      def init_log
        @log = {:deleted => [], :added => [] }
      end
      
      def only_contains_deletions(hashmap)
        hashmap.each do |key, value|
          if value.is_a?(Hash) then
            return false unless only_contains_deletions(value)
          elsif value.is_a?(String)
            return false
          end
        end
        true
      end
      
      def build_tree(start_tree, treemap = nil, flush = false)
        existing_trees = {}
        formatter = TreeFormatter.new
        treemap ||= self.treemap
    
        if start_tree then
          treewalk = TreeWalk.new(@jrepo)
          treewalk.add_tree(start_tree)
          while treewalk.next
            filename = treewalk.get_name_string
            if treemap.keys.include?(filename) then
              kind = treewalk.isSubtree ? :tree : :blob
                if treemap[filename] == false then
                  @log[:deleted] << [kind, filename, treewalk.get_object_id(0)]
                else
                  existing_trees[filename] = treewalk.get_object_id(0) if kind == :tree
                end
            else
              mode = treewalk.isSubtree ? FileMode::TREE : FileMode::REGULAR_FILE
              formatter.append(filename.to_java_string, treewalk.get_file_mode(0), treewalk.get_object_id(0))
            end
          end
        end
    
        treemap.each do |object_name, data|
          case data
            when String
              blobid = write_blob(data)
              formatter.append(object_name.to_java_string, FileMode::REGULAR_FILE, blobid)
              @log[:added] << [:blob, object_name, blobid]
            when Hash
              next_tree = build_tree(existing_trees[object_name], data)
              formatter.append(object_name.to_java_string, FileMode::TREE, next_tree)
              @log[:added] << [:tree, object_name, next_tree] unless only_contains_deletions(data)
            end
        end
    
        result = @object_inserter.insert(formatter)
        @object_inserter.flush if flush
        result
      end
      
      def write_blob(contents, flush = false)
        blobid = @object_inserter.insert(Constants::OBJ_BLOB, contents.to_java_bytes)
        @object_inserter.flush if flush
        blobid
      end
      
    end
    
    class Index
      import org.eclipse.jgit.lib.CommitBuilder
      
      attr_accessor :treemap, :current_tree
      attr_reader :jrepo
      
      def initialize(repository, branch = nil)
        @treemap = {}
        @jrepo = RJGit.repository_type(repository)
        @treebuilder = TreeBuilder.new(@jrepo)
      end
      
      def add(path, data)
        path = path[1..-1] if path[0] == '/'
        path = path.split('/')
        filename = path.pop

        current = self.treemap

        path.each do |dir|
          current[dir] ||= {}
          node = current[dir]
          current = node
        end

        current[filename] = data
        @treemap
      end
  
      def delete(path)
        path = path[1..-1] if path[0] == '/'
        path = path.split('/')
        last = path.pop
    
        current = self.treemap
    
        path.each do |dir|
          current[dir] ||= {}
          node = current[dir]
          current = node
        end
    
        current[last] = false
        @treemap
      end
      
      def commit(message, author, parents = nil, ref = "refs/heads/#{Constants::MASTER}")
        @current_tree = @current_tree ? RJGit.tree_type(@current_tree) : @jrepo.resolve(ref+"^{tree}")
        @treebuilder.treemap = @treemap
        new_tree = @treebuilder.build_tree(@current_tree)
        return false if @current_tree && new_tree.name == @current_tree.name
        
        puts @current_tree.inspect
      
        parents = parents ? parents : @jrepo.resolve(ref+"^{commit}")
    
        cb = CommitBuilder.new
        pi = author.person_ident
        cb.setCommitter(pi)
        cb.setAuthor(pi)
        cb.setMessage(message)
        cb.setTreeId(new_tree)
          if parents.is_a?(Array) then
            parents.each {|p| cb.addParentId RJGit.commit_type(p)}
          elsif parents
            cb.addParentId(RJGit.commit_type(parents))
          end
    
        newhead = @treebuilder.object_inserter.insert(cb)
      
        # Point ref to the newest commit
        ru = @jrepo.updateRef(ref)
        ru.setNewObjectId(newhead)
        res = ru.forceUpdate.to_string
      
        @treebuilder.object_inserter.flush
        @treemap = {}
        log = @treebuilder.log
        @treebuilder.init_log
        return res, log
      end
      
      def self.successful?(result)
        ["NEW", "FAST_FORWARD"].include?(result)
      end
      
    end
    
  end
  
end


