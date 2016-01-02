module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :repo, :path, :jtree
    alias_method :get_name, :id
    RJGit.delegate_to(RevTree, :@jtree)
    include Enumerable
    
    def initialize(repository, mode, path, jtree)
      @jrepo = RJGit.repository_type(repository)
      @mode = mode
      @path = path
      @name = @path ? File.basename(path) : nil
      @jtree = jtree
      @id = ObjectId.to_string(jtree.get_id)
    end
    
    def data
      return @contents if @contents
      strio = StringIO.new
      RJGit::Porcelain.ls_tree(@jrepo, @path, Constants::HEAD, options={:print => true, :io => strio})
      @contents = strio.string
    end
    
    def contents_array
      @contents_ary ||= jtree_entries
    end
    
    def each(&block)
      contents_array.each(&block)
    end
    
    def blobs
      @content_blobs ||= contents_array.select {|x| x.is_a?(Blob)}
    end
    
    def trees
      @content_trees ||= contents_array.select {|x| x.is_a?(Tree)}
    end
    
    def /(file)
      treewalk = TreeWalk.forPath(@jrepo, file, @jtree)
      treewalk.nil? ? nil : 
        wrap_tree_or_blob(treewalk.get_file_mode(0), treewalk.get_path_string, treewalk.get_object_id(0))
    end
    
    def self.new_from_hashmap(repository, hashmap, base_tree = nil)
      jrepo = RJGit.repository_type(repository)
      tree_builder = Plumbing::TreeBuilder.new(jrepo)
      base_tree = RJGit.tree_type(base_tree)
      new_tree = tree_builder.build_tree(base_tree, hashmap, true)
      walk = RevWalk.new(jrepo)
      new_tree = walk.lookup_tree(new_tree)
      Tree.new(jrepo, TREE_TYPE, nil, new_tree)
    end
    
    def self.find_tree(repository, file_path, revstring=Constants::HEAD)
      jrepo = RJGit.repository_type(repository)
      return nil if jrepo.nil?
      last_commit = jrepo.resolve(revstring)
      return nil if last_commit.nil?

      walk = RevWalk.new(jrepo)
      commit = walk.parse_commit(last_commit)
      treewalk = TreeWalk.new(jrepo)
      jtree = commit.get_tree
      treewalk.add_tree(jtree)
      treewalk.set_filter(PathFilter.create(file_path))
      if treewalk.next
        jsubtree = walk.lookup_tree(treewalk.object_id(0))
        if jsubtree
          mode = RJGit.get_file_mode_with_path(jrepo, file_path, jtree) 
          Tree.new(jrepo, mode, file_path, jsubtree)
        end
      else
        nil
      end
    end

    private

    def jtree_entries
      treewalk = TreeWalk.new(@jrepo)
      treewalk.add_tree(@jtree)
      entries = []
      while treewalk.next
        entries << wrap_tree_or_blob(treewalk.get_file_mode(0), treewalk.get_path_string, treewalk.get_object_id(0))
      end
      entries
    end

    def wrap_tree_or_blob(mode, path, id)
      type = mode.get_object_type == Constants::OBJ_TREE ? RJGit::Tree : RJGit::Blob
      walk = RevWalk.new(@jrepo)
      type.new(@jrepo, mode.get_bits, path, walk.parse_any(id)) 
    end
    
  end
  
end