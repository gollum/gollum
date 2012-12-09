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
    attr_reader :revcommit
    attr_reader :count
  
    RJGit.delegate_to(RevCommit, :@revcommit)
    
    def initialize(commit)
      @revcommit = commit
      @id = ObjectId.to_string(commit.get_id)
      @actor = Actor.new(@revcommit.get_author_ident)
      @committer = Actor.new(@revcommit.get_committer_ident)
      @committed_date = Time.at(@revcommit.commit_time)
      @message = @revcommit.get_full_message
      @short_message = @revcommit.get_short_message
      @count = @revcommit.get_parent_count
    end
  
    def parents
      @parents ||= @revcommit.get_parents.map{|parent| Commit.new(parent) }
    end
    
    def self.find_all(repository, ref, options)
      repository = RJGit.repository_type(repository)
      return nil if repository.nil?
      begin
        walk = RevWalk.new(repository);
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
