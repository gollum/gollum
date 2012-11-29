module RJGit
  
  import 'org.eclipse.jgit.revwalk.RevBlob'
  
  class Blob 
    DEFAULT_MIME_TYPE = "text/plain"

    attr_reader :id, :mode, :name, :blob
    RJGit.delegate_to(RevBlob, :@blob)

    def initialize(repo, name, blob)
      @repo = repo
      @blob = blob
      @name = name
      @id = ObjectId.toString(blob.get_id)
    end
    
    # The size of this blob in bytes
    #
    # Returns Integer
    def size
      @size ||= @repo.git.cat_file({:s => true}, id).chomp.to_i
    end

    # The binary contents of this blob.
    #
    # Returns String
    def data
      @data ||= RJGit::Porcelain.cat_file(@repo, @blob) #@repo.git.cat_file({:p => true}, id)
    end

    # The mime type of this file (based on the filename)
    #
    # Returns String
    def mime_type
      guesses = MIME::Types.type_for(self.name) rescue []
      guesses.first ? guesses.first.simplified : DEFAULT_MIME_TYPE
    end

    
    def self.find_blob(repository, file_path, branch=Constants::HEAD)
      lastCommitHash = repository.resolve(branch)
      return nil if lastCommitHash.nil?

      walk = RevWalk.new(repository)
      commit = walk.parseCommit(lastCommitHash)
      treeWalk = TreeWalk.new(repository)
      treeWalk.addTree(commit.getTree)
      treeWalk.setRecursive(true)
      treeWalk.setFilter(PathFilter.create(file_path))
      if treeWalk.next
        revBlob = walk.lookupBlob(treeWalk.objectId(0));
        revBlob.nil? ? nil : Blob.new(repository, File.basename(file_path), revBlob)
      else
        nil
      end
    end

  end
end
