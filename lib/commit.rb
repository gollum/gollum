module RJGit

  import 'org.eclipse.jgit.revwalk.RevWalk'
  import 'org.eclipse.jgit.revwalk.RevCommit'

  class Commit

    attr_reader :id
    attr_reader :parents
    attr_reader :actor
    attr_reader :committer
    attr_reader :authored_date
    attr_reader :committed_date
    attr_reader :message
    attr_reader :short_message
    attr_reader :jcommit
    attr_reader :count
  
    RJGit.delegate_to(RevCommit, :@jcommit)
    
    def initialize(commit)
      @jcommit = commit
      @id = ObjectId.to_string(commit.get_id)
      @actor = Actor.new(@jcommit.get_author_ident)
      @committer = Actor.new(@jcommit.get_committer_ident)
      @committed_date = Time.at(@jcommit.commit_time)
      @message = @jcommit.get_full_message
      @short_message = @jcommit.get_short_message
      @count = @jcommit.get_parent_count
    end
  
    def parents
      @parents ||= @jcommit.get_parents.map{|parent| Commit.new(parent) }
    end
    
    def self.find_all(repository, ref, options)
      repository = RJGit.repository_type(repository)
      return nil if repository.nil?
      begin
        walk = RevWalk.new(repository)
        objhead = repository.resolve(ref)
        root = walk.parse_commit(objhead)
        walk.mark_start(root)
        commits = walk.map { |commit| Commit.new(commit) }
        return commits.first(options[:limit])
      rescue NativeException => e
        return Array.new
      end
    end
  
    def self.diff(repo, a, b = nil, paths = [], options = {})
    end
    
    
  end
end
