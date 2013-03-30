module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  import 'org.eclipse.jgit.storage.file.FileRepository'
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
    
    def initialize(path, options = {}, create = false)
      epath = File.expand_path(path)

      bare = false
      if File.exist?(File.join(epath, '/.git'))
        bare = false
      elsif File.exist?(epath) || options[:bare]
        bare = true
      end

      @path = bare ? epath : File.join(epath, '/.git')
      @config = RJGit::Configuration.new(File.join(@path, 'config'))
      repo_path = java.io.File.new(@path)
      @jrepo = bare ? RepositoryBuilder.new().set_bare.set_git_dir(repo_path).build() : RepositoryBuilder.new().set_git_dir(repo_path).build()
      @jrepo.create(bare) if create
      @git = RubyGit.new(@jrepo)
    end
    
    def bare?
      @jrepo.is_bare
    end

    def self.create(path, options = {:bare => false})
      Repo.new(path, options, true)
    end

    def commits(ref="master", limit=100)
      options = { :limit => limit }
      Commit.find_all(@jrepo, ref, options)
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

    # Convenience method to retrieve a Blob by name
    def blob(file_path)
      Blob.find_blob(@jrepo, file_path)
    end

    # Convenience method to retrieve a Tree by name
    def tree(file_path)
      Tree.find_tree(@jrepo, file_path)
      
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
