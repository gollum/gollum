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
    
    def initialize(commit, repository)
      @jcommit = commit
      @jrepo = RJGit.repository_type(repository)
      @id = ObjectId.to_string(commit.get_id)
      @actor = Actor.new_from_person_ident(@jcommit.get_author_ident)
      @committer = Actor.new_from_person_ident(@jcommit.get_committer_ident)
      @committed_date = Time.at(@jcommit.commit_time)
      @message = @jcommit.get_full_message
      @short_message = @jcommit.get_short_message
      @count = @jcommit.get_parent_count
    end
    
    def tree
      @tree ||= Tree.new(@jrepo, FileMode::TREE, nil, @jcommit.get_tree)
    end
  
    def parents
      @parents ||= @jcommit.get_parents.map{|parent| Commit.new(parent, @jrepo) }
    end
    
    def self.new_with_tree(repository, tree, message, actor, parents = nil)
      repository = RJGit.repository_type(repository)
      parents = parents ? parents : repository.resolve("refs/heads/#{Constants::MASTER}")
      new_commit = RJGit::Plumbing::Index.new(repository).do_commit(message, actor, parents, tree)
      Commit.new(RevWalk.new(repository).parseCommit(new_commit), repository)
    end
    
    def self.find_head(repository)
      repository = RJGit.repository_type(repository)
      return nil if repository.nil?
      begin
        walk = RevWalk.new(repository)
        objhead = repository.resolve(Constants::HEAD)
        return Commit.new(walk.parseCommit(objhead), repository)
      rescue NativeException => e
        return nil
      end
    end
    
    def self.find_all(repository, ref, options)
      repository = RJGit.repository_type(repository)
      return nil if repository.nil?
      begin
        walk = RevWalk.new(repository)
        objhead = repository.resolve(ref)
        root = walk.parse_commit(objhead)
        walk.mark_start(root)
        commits = walk.map { |commit| Commit.new(commit, repository) }
        return commits.first(options[:limit])
      rescue NativeException => e
        return Array.new
      end
    end
  
    def self.diff(repo, a, b = nil, paths = [], options = {})
    end
    
    
  end
end
