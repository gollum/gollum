module RJGit
  
  import 'org.eclipse.jgit.revwalk' 
  import 'org.eclipse.jgit.revwalk.RevTag'
  
  class Tag

    attr_reader :id, :jtag
    RJGit.delegate_to(RevTag, :@jtag)
    
    def initialize(jtag)
      @jtag = jtag
      @id = ObjectId.to_string(jtag.get_id)
    end
    
    def full_message
      @full_message ||= @jtag.get_full_message
    end
    
    def short_message
      @short_message ||= @jtag.get_short_message
    end 
    
    def actor
      @actor ||= Actor.new_from_person_ident(@jtag.get_tagger_ident)
    end
    
    def name
      @name ||= @jtag.get_tag_name
    end

    def type
      @type ||= @jtag.get_type
    end
    
    
  end
end