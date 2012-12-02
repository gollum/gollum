module RJGit
  
  import 'org.eclipse.jgit.revwalk.RevBlob'
  
  class Blob 
    
    attr_reader :id, :mode, :name, :path, :blob
    RJGit.delegate_to(RevBlob, :@blob)

    def initialize(repo, path, mode, blob)
      @repo = repo
      @blob = blob
      @path = path
      @name = File.basename(path)
      @mode = mode
      @id = ObjectId.toString(blob.get_id)
    end
    
    # The size of this blob in bytes
    #
    # Returns Integer
    def bytesize
      @bytesize ||= @repo.open(@blob).get_size 
    end

    def size
      @size ||= bytesize
    end
    
    def blame(options={})
      @blame ||= RJGit::Porcelain.blame(@repo, @path, options)
    end

    # The binary contents of this blob.
    # Returns String
    def data
      @data ||= RJGit::Porcelain.cat_file(@repo, @blob) 
    end

    # The mime type of this file (based on the filename)
    # Returns String
    def mime_type
      Blob.mime_type(self.name)
    end

    def self.mime_type(filename)
      guesses = MIME::Types.type_for(filename) rescue []
      guesses.first ? guesses.first.simplified : DEFAULT_MIME_TYPE
    end
    
    # Finds a particular Blob in repository matching file_path
    def self.find_blob(repository, file_path, branch=Constants::HEAD)
      last_commit_hash = repository.resolve(branch)
      return nil if last_commit_hash.nil?

      walk = RevWalk.new(repository)
      commit = walk.parse_commit(last_commit_hash)
      treewalk = TreeWalk.new(repository)
      revtree = commit.get_tree
      treewalk.add_tree(revtree)
      treewalk.set_recursive(true)
      treewalk.set_filter(PathFilter.create(file_path))
      if treewalk.next
        revblob = walk.lookup_blob(treewalk.objectId(0))
        if revblob
          mode = RJGit.get_file_mode(repository, file_path, revtree) 
          Blob.new(repository, file_path, mode, revblob)
        end
      else
        nil
      end
    end

  end
end
