module RJGit
  
  import 'org.eclipse.jgit.revwalk.RevBlob'
  
  class Blob 
    
    attr_reader :id, :mode, :name, :blob
    RJGit.delegate_to(RevBlob, :@blob)

    def initialize(repo, name, mode, blob)
      @repo = repo
      @blob = blob
      @name = name
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
      lastCommitHash = repository.resolve(branch)
      return nil if lastCommitHash.nil?

      walk = RevWalk.new(repository)
      commit = walk.parseCommit(lastCommitHash)
      treeWalk = TreeWalk.new(repository)
      revTree = commit.getTree
      treeWalk.addTree(revTree)
      treeWalk.setRecursive(true)
      treeWalk.setFilter(PathFilter.create(file_path))
      if treeWalk.next
        revBlob = walk.lookupBlob(treeWalk.objectId(0))
        if revBlob
          mode = RJGit.get_file_mode(repository, file_path, revTree) 
          Blob.new(repository, File.basename(file_path), mode, revBlob)
        end
      else
        nil
      end
    end

  end
end
