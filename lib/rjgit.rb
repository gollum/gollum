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

  require 'uri'
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

    import 'org.eclipse.jgit.lib.Constants'
    import 'org.eclipse.jgit.api.AddCommand'
    import 'org.eclipse.jgit.api.CommitCommand'
    import 'org.eclipse.jgit.api.BlameCommand'
    import 'org.eclipse.jgit.blame.BlameGenerator'
    import 'org.eclipse.jgit.blame.BlameResult'
    import 'org.eclipse.jgit.treewalk.CanonicalTreeParser'
    import 'org.eclipse.jgit.diff.DiffFormatter'

    # http://wiki.eclipse.org/JGit/User_Guide#Porcelain_API
    def self.add(repository, file_pattern)
      repository.add(file_pattern)
    end

    def self.commit(repository, message="")
      repository.commit(message)
    end

    def self.object_for_tag(repository, tag)
      repository.find(tag.object.name, RJGit.sym_for_type(tag.object_type))
    end

    # http://dev.eclipse.org/mhonarc/lists/jgit-dev/msg00558.html
    def self.cat_file(repository, blob)
      jrepo = RJGit.repository_type(repository)
      jblob = RJGit.blob_type(blob)
      # Try to resolve symlinks; return nil otherwise
      mode = RJGit.get_file_mode(jrepo, jblob)
      if mode == SYMLINK_TYPE
        symlink_source = jrepo.open(jblob.id).get_bytes.to_a.pack('c*').force_encoding('UTF-8')
        blob = Blob.find_blob(jrepo, symlink_source)
        return nil if blob.nil?
        jblob = blob.jblob
      end
      bytes = jrepo.open(jblob.id).get_bytes
      return bytes.to_a.pack('c*').force_encoding('UTF-8')
    end

    def self.ls_tree(repository, path=nil, treeish=Constants::HEAD, options={})
      options = {recursive: false, print: false, io: $stdout, path_filter: nil}.merge options
      jrepo = RJGit.repository_type(repository)
      ref = treeish.respond_to?(:get_name) ? treeish.get_name : treeish

      begin
        obj = jrepo.resolve(ref)
        walk = RevWalk.new(jrepo)
        revobj = walk.parse_any(obj)
        jtree = case revobj.get_type
        when Constants::OBJ_TREE
          walk.parse_tree(obj)
        when Constants::OBJ_COMMIT
          walk.parse_commit(obj).get_tree
        end
      rescue Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException, Java::JavaLang::NullPointerException
        return nil
      end
      if path
        treewalk = TreeWalk.forPath(jrepo, path, jtree)
        return nil unless treewalk
        treewalk.enter_subtree
      else
        treewalk = TreeWalk.new(jrepo)
        treewalk.add_tree(jtree)
      end
      treewalk.set_recursive(options[:recursive])
      treewalk.set_filter(PathFilter.create(options[:path_filter])) if options[:path_filter]
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
        blameline[:actor] = Actor.new_from_person_ident(result.get_source_author(index))
        blameline[:line] = result.get_source_line(index)
        blameline[:commit] = Commit.new(repository, result.get_source_commit(index))
        blameline[:line] = content.get_string(index)
        blame << blameline
      end
      options[:io].puts RJGit.stringify(blame) if options[:print]
      return blame
    end

    def self.diff(repository, options = {})
      options = {:namestatus => false, :patch => false}.merge(options)
      repo = RJGit.repository_type(repository)
      git = RubyGit.new(repo).jgit
      diff_command = git.diff
      [:old, :new].each do |which_rev|
        if rev = options["#{which_rev}_rev".to_sym]
          reader = repo.new_object_reader
          parser = CanonicalTreeParser.new
          parser.reset(reader, repo.resolve("#{rev}^{tree}"))
          diff_command.send("set_#{which_rev}_tree".to_sym, parser)
        end
      end
      diff_command.set_path_filter(PathFilter.create(options[:file_path])) if options[:file_path]
      diff_command.set_show_name_and_status_only(true) if options[:namestatus]
      diff_command.set_cached(true) if options[:cached]
      diff_entries = diff_command.call
      diff_entries = diff_entries.to_array.to_ary
        if options[:patch]
          result = []
          out_stream = ByteArrayOutputStream.new
          formatter = DiffFormatter.new(out_stream)
          formatter.set_repository(repo)
          diff_entries.each do |diff_entry|
            formatter.format(diff_entry)
            result.push [diff_entry, out_stream.to_string]
            out_stream.reset
          end
        end
      diff_entries = options[:patch] ? result : diff_entries.map {|entry| [entry]}
      RJGit.convert_diff_entries(diff_entries)
    end

  end

  module Plumbing
    import org.eclipse.jgit.lib.Constants

    class TreeBuilder
      import org.eclipse.jgit.lib.FileMode
      import org.eclipse.jgit.lib.TreeFormatter
      import org.eclipse.jgit.patch.Patch

      attr_accessor :treemap
      attr_reader :log

      def initialize(repository)
        @jrepo = RJGit.repository_type(repository)
        @treemap = {}
        init_log
      end

      def object_inserter
        @object_inserter ||= @jrepo.newObjectInserter
      end

      def init_log
        @log = {:deleted => [], :added => [] }
      end

      def only_contains_deletions(hashmap)
        hashmap.each do |key, value|
          if value.is_a?(Hash)
            return false unless only_contains_deletions(value)
          elsif value.is_a?(String)
            return false
          end
        end
        true
      end

      def build_tree(start_tree, treemap = nil, flush = false)
        existing_trees = {}
        untouched_objects = {}
        formatter = TreeFormatter.new
        treemap ||= self.treemap
        if start_tree
          treewalk = TreeWalk.new(@jrepo)
          treewalk.add_tree(start_tree)
          while treewalk.next
            filename = treewalk.get_name_string
            if treemap.keys.include?(filename)
              kind = treewalk.isSubtree ? :tree : :blob
                if treemap[filename] == false
                  @log[:deleted] << [kind, filename, treewalk.get_object_id(0)]
                else
                  existing_trees[filename] = treewalk.get_object_id(0) if kind == :tree
                end
            else
              mode = treewalk.get_file_mode(0)
              filename = "#{filename}/" if mode == FileMode::TREE
              untouched_objects[filename] = [mode, treewalk.get_object_id(0)]
            end
          end
        end

        sorted_treemap = treemap.inject({}) {|h, (k,v)| v.is_a?(Hash) ? h["#{k}/"] = v : h[k] = v; h }.merge(untouched_objects).sort
        sorted_treemap.each do |object_name, data|
          case data
            when Array
              object_name = object_name[0...-1] if data[0] == FileMode::TREE
              formatter.append(object_name.to_java_string, data[0], data[1])
            when Hash
              object_name = object_name[0...-1]
              next_tree = build_tree(existing_trees[object_name], data)
              formatter.append(object_name.to_java_string, FileMode::TREE, next_tree)
              @log[:added] << [:tree, object_name, next_tree] unless only_contains_deletions(data)
            when String
              blobid = write_blob(data)
              formatter.append(object_name.to_java_string, FileMode::REGULAR_FILE, blobid)
              @log[:added] << [:blob, object_name, blobid]
            end
        end
        object_inserter.insert(formatter)
      end

      def write_blob(contents, flush = false)
        blobid = object_inserter.insert(Constants::OBJ_BLOB, contents.to_java_bytes)
        object_inserter.flush if flush
        blobid
      end

    end

    class Index
      import org.eclipse.jgit.lib.CommitBuilder

      attr_accessor :treemap, :current_tree
      attr_reader :jrepo

      def initialize(repository)
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

      def do_commit(message, author, parents, new_tree)
        commit_builder = CommitBuilder.new
        person = author.person_ident
        commit_builder.setCommitter(person)
        commit_builder.setAuthor(person)
        commit_builder.setMessage(message)
        commit_builder.setTreeId(RJGit.tree_type(new_tree))
        if parents.is_a?(Array)
          parents.each {|parent| commit_builder.addParentId(RJGit.commit_type(parent)) }
        elsif parents
          commit_builder.addParentId(RJGit.commit_type(parents))
        end
        result = @treebuilder.object_inserter.insert(commit_builder)
        @treebuilder.object_inserter.flush
        result
      end

      def commit(message, author, parents = nil, ref = "refs/heads/#{Constants::MASTER}", force = false)
        new_tree = build_new_tree(@treemap, "#{ref}^{tree}")
        return false if @current_tree && new_tree.name == @current_tree.name

        parents = parents ? parents : @jrepo.resolve(ref+"^{commit}")
        new_head = do_commit(message, author, parents, new_tree)

        # Point ref to the newest commit
        ru = @jrepo.updateRef(ref)
        ru.setNewObjectId(new_head)
        ru.setForceUpdate(force)
        ru.setRefLogIdent(author.person_ident)
        ru.setRefLogMessage("commit: #{message}", false)
        res = ru.update.to_string

        @current_tree = new_tree
        log = @treebuilder.log
        @treebuilder.init_log
        sha =  ObjectId.to_string(new_head)
        return res, log, sha
      end

      def self.successful?(result)
        ["NEW", "FAST_FORWARD", "FORCED"].include?(result)
      end
      
      private
      
      def build_new_tree(treemap, ref)
        @treebuilder.treemap = treemap
        new_tree = @treebuilder.build_tree(@current_tree ? RJGit.tree_type(@current_tree) : @jrepo.resolve(ref))
      end

    end

    class ApplyPatchToIndex < RJGit::Plumbing::Index

      import org.eclipse.jgit.patch.Patch
      import org.eclipse.jgit.diff.DiffEntry

      ADD    = org.eclipse.jgit.diff.DiffEntry::ChangeType::ADD
      COPY   = org.eclipse.jgit.diff.DiffEntry::ChangeType::COPY
      MODIFY = org.eclipse.jgit.diff.DiffEntry::ChangeType::MODIFY
      DELETE = org.eclipse.jgit.diff.DiffEntry::ChangeType::DELETE
      RENAME = org.eclipse.jgit.diff.DiffEntry::ChangeType::RENAME

      # Take the result of RJGit::Porcelain.diff with options[:patch] = true and return a patch String
      def self.diffs_to_patch(diffs)
        diffs.inject(""){|result, diff| result << diff[:patch]}
      end

      def initialize(repository, patch, ref = Constants::HEAD)
        super(repository)
        @ref   = ref
        @patch = Patch.new
        @patch.parse(ByteArrayInputStream.new(patch.to_java_bytes))
        raise_patch_apply_error unless @patch.getErrors.isEmpty()
        @current_tree = Commit.find_head(@jrepo, ref).tree
      end

      def commit(message, author, parents = nil, force = false)
        super(message, author, parents, @ref, force)
      end

      def build_map
        raise_patch_apply_error if @patch.getFiles.isEmpty()
        @patch.getFiles.each do |file_header|
          case file_header.getChangeType
          when ADD
            add(file_header.getNewPath, apply('', file_header))
          when MODIFY
            add(file_header.getOldPath, apply(getData(file_header.getOldPath), file_header))
          when DELETE
            delete(file_header.getOldPath)
          when RENAME
            delete(file_header.getOldPath)
            add(file_header.getNewPath, getData(file_header.getOldPath))
          when COPY
            add(file_header.getNewPath, getData(file_header.getOldPath))
          end
        end
        @treemap
      end
      
      # Build the new tree based on the patch, but don't commit it
      # Return the String object id of the new tree, and an Array of affected paths
      def new_tree
        map = build_map
        return ObjectId.to_string(build_new_tree(map, @ref)), map.keys
      end

      private

      def raise_patch_apply_error
        raise ::RJGit::PatchApplyException.new('Patch failed to apply')
      end

      def getData(path)
        begin
          (@current_tree / path).data
        rescue NoMethodError
          raise_patch_apply_error
        end
      end

      def hunk_sanity_check(hunk, hunk_line, pos, newLines)
        raise_patch_apply_error unless newLines[hunk.getNewStartLine - 1 + pos] == hunk_line[1..-1]
      end

      def apply(original, file_header)
        newLines = original.lines
        file_header.getHunks.each do |hunk|
          length = hunk.getEndOffset - hunk.getStartOffset
          buffer_text = hunk.getBuffer.to_s.slice(hunk.getStartOffset, length)
          pos = 0
          buffer_text.each_line do |hunk_line|
            case hunk_line[0]
              when ' '
                hunk_sanity_check(hunk, hunk_line, pos, newLines)
                pos += 1
              when '-'
                if hunk.getNewStartLine == 0
                  newLines = []
                else
                  hunk_sanity_check(hunk, hunk_line, pos, newLines)
                  newLines.slice!(hunk.getNewStartLine - 1 + pos)
                end
              when '+'
                newLines.insert(hunk.getNewStartLine - 1 + pos, hunk_line[1..-1])
                pos += 1
            end
          end
        end
        newLines.join
      end
    end

  end

end
