module RJGit

  # PersonIdent in JGit
  import 'org.eclipse.jgit.lib.PersonIdent'
  
  class Actor

    attr_reader :name, :email, :person_ident
    
    RJGit.delegate_to(PersonIdent, :@person_ident)
    
    def self.new_from_name_and_email(name, email)
      return self.new(PersonIdent.new(name, email))
    end
    alias_method :to_s, :name

    def initialize(person_ident)
      @name = person_ident.get_name
      @email = person_ident.get_email_address
      @person_ident = person_ident
    end
    
    # Create an Actor from a string.
    #
    # str - The String in this format: 'John Doe <jdoe@example.com>'
    #
    # Returns Git::Actor.
    def self.from_string(str)
      if str =~ /<.+>/
        m, name, email = *str.match(/(.*) <(.+?)>/)
        return self.new_from_name_and_email(name, email)
      end
    end

    # Outputs an actor string for Git commits.
    #
    # actor = Actor.new('bob', 'bob@email.com')
    # actor.output(time) # => "bob <bob@email.com> UNIX_TIME +0700"
    #
    # time - The Time the commit was authored or committed.
    #
    # Returns a String.
    def output(time)
      offset = time.utc_offset / 60
      "%s <%s> %d %+.2d%.2d" % [
        @name,
        @email || "null",
        time.to_i,
        offset / 60,
        offset.abs % 60]
    end

  end 

end