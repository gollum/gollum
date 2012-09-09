module RJGit
  
  class Blob
    DEFAULT_MIME_TYPE = "text/plain"

    attr_reader :id
    attr_reader :mode
    attr_reader :name
    
    
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
    
  end
end