module RJGit

  require 'delegate'
  
  class Blob < Delegator
    DEFAULT_MIME_TYPE = "text/plain"

    attr_reader :id
    attr_reader :mode
    attr_reader :name

    def initialize(repo, blob)
      @repo = repo
      @backingBlob = blob
      super(@backingBlob)
    end

    def __getobj__ ; @backingBlob ; end    
    def __setobj__(obj) ; @backingBlob = obj ; end
    
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
      @data ||= @repo.git.cat_file({:p => true}, id)
    end

    # The mime type of this file (based on the filename)
    #
    # Returns String
    def mime_type
      guesses = MIME::Types.type_for(self.name) rescue []
      guesses.first ? guesses.first.simplified : DEFAULT_MIME_TYPE
    end

    def data
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
        revBlob.nil? ? nil : Blob.new(repository, revBlob)
      else
        nil
      end
    end

  end
end
