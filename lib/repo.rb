module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  import 'org.eclipse.jgit.treewalk.TreeWalk'
  import 'org.eclipse.jgit.treewalk.filter.PathFilter'
  import 'org.eclipse.jgit.lib.Constants'
  import 'org.eclipse.jgit.lib.RefWriter'
  import 'java.io.IOException'
  
  # Implementation of RefWriter for local files. This class is able to generate and write the $GIT_DIR/info/refs. For use in Repo::update_server_info.
  class LocalRefWriter < RefWriter
    attr_accessor :path
    
    def initialize(refs, path)
      super(refs)
      @path = path
    end
    
    def writeFile(file, content)
        file = File.join(@path, file)
      begin
        f = File.open(file, "w")
        f.write String.from_java_bytes(content)
        f.close
      rescue
        raise IOException.new # JGit API requires RefWriter.writeFile to throw IOException
      end
    end
    
  end
  
  class Repo
    
    attr_accessor :git
    attr_accessor :jrepo
    attr_accessor :path
    
    PACK_LIST = 'objects/info/packs'

    RJGit.delegate_to(Repository, :@jrepo)
    
    def initialize(path, options = {})
      epath = File.expand_path(path)
      gitpath = File.join(epath, '.git')
      
      # Default value for bare
      bare = false
      # If the repo path is new
      unless File.exists?(epath) 
        # take user setting if defined
        bare = !! options[:is_bare] unless options[:is_bare].nil?
      # If the repo path exists
      else
        # scan the directory for a .git directory
        bare = File.exists?(gitpath) ? false : true
        # but allow overriding user setting
        bare = !! options[:is_bare] unless options[:is_bare].nil? 
      end
      
      @path = bare ? epath : gitpath
      @config = RJGit::Configuration.new(File.join(@path, 'config'))
      repo_path = java.io.File.new(@path)
      @jrepo = bare ? RepositoryBuilder.new().set_bare.set_git_dir(repo_path).build() : RepositoryBuilder.new().set_git_dir(repo_path).build()
      @jrepo.create(bare) if options[:create]
      @git = RubyGit.new(@jrepo)
    end
    
    def bare?
      @jrepo.is_bare
    end
    alias_method :bare, :bare?
    
    def self.create(path, options = {:is_bare => false})
      options[:create] = true
      Repo.new(path, options)
    end
    
    def create!
      @jrepo.create(self.bare?)
    end

    def commits(ref="master", limit=100)
      options = { :limit => limit }
      Commit.find_all(@jrepo, ref, options)
    end
    
    def head
      Commit.find_head(@jrepo)
    end
    
    def valid?
      @jrepo.get_object_database.exists
    end

    def config
      @config.load
    end
    
    def branch
      @jrepo.get_full_branch
    end

    def branches
      return @git.branch_list
    end
    
    def create_branch(name)
      @git.create_branch(name)
    end
    
    def delete_branch(name)
      @git.delete_branch(name)
    end
    
    def rename_branch(old_name, new_name)
      @git.rename_branch(old_name, new_name)
    end
    
    def checkout(branch_name, options = {})
      @git.checkout(branch_name, options)
    end
    alias_method :switch, :checkout
    
    
    def tags(lightweight = false)
      jtags = @jrepo.get_tags.to_hash
      if lightweight
        jtags.each_with_object( Hash.new ) do |(key, value), hash| 
          hash[key] = ObjectId.to_string(value.get_object_id)
        end
      else
        tags = Hash.new
        jtags.each do |key, value|
          jtag = @git.resolve_tag(value)
          if jtag
            tag = Tag.new(jtag)
            tags[key] = tag 
          end
        end
        tags
      end
    end

    def add(file_pattern)
      @git.add(file_pattern)
    end
    
    def remove(file_pattern)
      @git.remove(file_pattern)
    end
    
    def commit(message)
      @git.commit(message)
    end
    
    def clean(options = {})
      @git.clean(options)
    end
    
    def find(sha, type)
      oi = ObjectId.from_string(sha)
      walk = RevWalk.new(@jrepo)
        begin
        result = case type
          when :tree
            Tree.new(@jrepo, nil, nil, walk.parse_tree(oi))
          when :blob
            Blob.new(@jrepo, nil, nil, walk.parse_any(oi))
          when :tag
            Tag.new(walk.parse_tag(oi))
          when :commit
            Commit.new(jrepo, walk.parse_commit(walk.lookup_commit(oi)))
          else nil
          end
        rescue Java::OrgEclipseJgitErrors::MissingObjectException, Java::JavaLang::IllegalArgumentException
          nil
        end
    end

    # Convenience method to retrieve a Blob by name
    def blob(file_path, revstring=Constants::HEAD)
      Blob.find_blob(@jrepo, file_path, revstring)
    end

    # Convenience method to retrieve a Tree by name
    def tree(file_path, revstring=Constants::HEAD)
      Tree.find_tree(@jrepo, file_path, revstring)
    end
    
    def update_ref(commit, force = false, ref = "refs/heads/#{Constants::MASTER}")
      ref_updater = @jrepo.updateRef(ref)
      ref_updater.setNewObjectId(RJGit.commit_type(commit))
      msg = force ? :update : :forceUpdate
      ref_updater.send(msg).to_string
    end
    
    # Update the info files required for fetching files over the dump-HTTP protocol
    def update_server_info
      # First update the $GIT_DIR/refs/info file
      refs = @jrepo.get_all_refs # Note: JGit will include directories under $GIT_DIR/refs/heads that start with a '.' in its search for refs. Filter these out in LocalRefWriter?
      writer = LocalRefWriter.new(refs, @path)
      writer.write_info_refs
      
      # Now update the $GIT_OBJECT_DIRECTORY/info/packs file
      f = File.new(File.join(@path, PACK_LIST), "w")
      @jrepo.get_object_database.get_packs.each do |pack|
        f.write "P " + pack.get_pack_file.get_name + "\n"
      end
      f.write "\n"
      f.close
      
      return true
    end 

  end

end
