module RJGit

  # PersonIdent in JGit
  import 'org.eclipse.jgit.lib.PersonIdent'
  import 'java.util.TimeZone'
  
  class Actor

    attr_reader :name, :email, :person_ident
    
    RJGit.delegate_to(PersonIdent, :@person_ident)
    
    alias_method :to_s, :name
      
    def self.new_from_person_ident(person_ident)
      name = person_ident.get_name
      email = person_ident.get_email_address
      return self.new(name, email)
    end
    
    def initialize(name, email, time = nil)
      @name = name
      @email = email
      @time = time
      @person_ident = @time ? PersonIdent.new(name, email, time.to_java, TimeZone.getTimeZone(time.zone)) : PersonIdent.new(name, email)
    end
    
    # Create an Actor from a string.
    #
    # str - The String in this format: 'John Doe <jdoe@example.com>'
    #
    # Returns Git::Actor.
    def self.from_string(str)
      if str =~ /<.+>/
        m, name, email = *str.match(/(.*) <(.+?)>/)
        return self.new(name, email)
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
    def output(time = nil)
      time = time || self.time
      offset = time.utc_offset / 60
      "%s <%s> %d %+.2d%.2d" % [
        @name,
        @email || "null",
        time.to_i,
        offset / 60,
        offset.abs % 60]
    end
    
    def time
      Time.at(@person_ident.getWhen.getTime/1000)
    end

  end 

end