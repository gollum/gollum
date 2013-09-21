module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTree'
  
  class Tree 

    attr_reader :contents, :id, :mode, :name, :repo, :jtree
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
      RJGit::Porcelain.ls_tree(@jrepo, @jtree, options={:print => true, :io => strio})
      @contents = strio.string
    end
    
    def contents_array
      return @contents_ary if @contents_ary
      results = []
      RJGit::Porcelain.ls_tree(@jrepo, @jtree).each do |item|
        walk = RevWalk.new(@jrepo)
        results << Tree.new(@jrepo, item[:mode], item[:path], walk.lookup_tree(ObjectId.from_string(item[:id]))) if item[:type] == 'tree'
        results << Blob.new(@jrepo, item[:mode], item[:path], walk.lookup_blob(ObjectId.from_string(item[:id]))) if item[:type] == 'blob'
      end
      @contents_ary = results
    end
    
    def each(&block)
      contents_array.each(&block)
    end
    
    def blobs
      contents_array.select {|x| x.is_a?(Blob)}
    end
    
    def trees
      contents_array.select {|x| x.is_a?(Tree)}
    end
    
    def self.make_tree(repository, hashmap, base_tree = nil)
      jrepo = RJGit.repository_type(repository)
      tb = Plumbing::TreeBuilder.new(jrepo)
      base_tree = RJGit.tree_type(base_tree)
      new_tree = tb.build_tree(base_tree, hashmap, true)
      walk = RevWalk.new(jrepo)
      new_tree = walk.lookup_tree(new_tree)
      Tree.new(jrepo, FileMode::TREE, nil, new_tree)
    end
    
    def self.find_tree(repository, file_path, revstring=Constants::HEAD)
      jrepo = RJGit.repository_type(repository)
      return nil if jrepo.nil?
      last_commit_hash = jrepo.resolve(revstring)
      return nil if last_commit_hash.nil?

      walk = RevWalk.new(jrepo)
      commit = walk.parse_commit(last_commit_hash)
      treewalk = TreeWalk.new(jrepo)
      jtree = commit.get_tree
      treewalk.add_tree(jtree)
      treewalk.set_filter(PathFilter.create(file_path))
      if treewalk.next
        jsubtree = walk.lookup_tree(treewalk.object_id(0))
        if jsubtree
          mode = RJGit.get_file_mode(jrepo, file_path, jtree) 
          Tree.new(jrepo, mode, file_path, jsubtree)
        end
      else
        nil
      end
    end
    
  end
  
end