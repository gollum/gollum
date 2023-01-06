module RJGit
  
  class Note
    attr_reader :jnote, :message, :annotates
    DEFAULT_REF = "refs/notes/commits"
    
    def initialize(repository, note)
      @jrepo = RJGit.repository_type(repository)
      @jnote = RJGit.note_type(note)
      @message = @jrepo.open(@jnote.getData()).get_bytes.to_a.pack('c*').force_encoding('UTF-8')
      @annotates = @jnote.to_s[5..44]
    end
    
    def to_s
      @message
    end
  end
end