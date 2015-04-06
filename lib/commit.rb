module RJGit

  import 'org.eclipse.jgit.revwalk.RevWalk'
  import 'org.eclipse.jgit.revwalk.RevCommit'
  import 'org.eclipse.jgit.diff.DiffFormatter'
  import 'org.eclipse.jgit.util.io.DisabledOutputStream'

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
    attr_reader :parent_count
  
    RJGit.delegate_to(RevCommit, :@jcommit)
    
    def initialize(repository, commit)
      @jrepo = RJGit.repository_type(repository)
      @jcommit = commit
      @id = ObjectId.to_string(commit.get_id)
      @actor = Actor.new_from_person_ident(@jcommit.get_author_ident)
      @committer = Actor.new_from_person_ident(@jcommit.get_committer_ident)
      @committed_date = Time.at(@jcommit.commit_time)
      @authored_date = Time.at(@jcommit.get_author_ident.when.time/1000)
      @message = @jcommit.get_full_message
      @short_message = @jcommit.get_short_message
      @parent_count = @jcommit.get_parent_count
    end
    
    def tree
      @tree ||= Tree.new(@jrepo, TREE_TYPE, nil, @jcommit.get_tree)
    end
  
    def parents
      @parents ||= @jcommit.get_parents.map {|parent| Commit.new(@jrepo, parent)}
    end

    def stats
      df = DiffFormatter.new(DisabledOutputStream::INSTANCE)
      df.set_repository(@jrepo)
      df.set_context(0)
      entries = df.scan(@jcommit.get_parents[0], @jcommit)
      results = {}
      total_del = 0
      total_ins = 0
      entries.each do |entry|
        file = df.toFileHeader(entry)
        del = 0
        ins = 0
        file.getHunks.each do |hunk|
            hunk.toEditList.each do |edit|
              del += edit.getEndA - edit.getBeginA
              ins += edit.getEndB - edit.getBeginB
            end
        end
        total_del += del
        total_ins += ins
        results[file.getNewPath] = [ins, del, ins + del]
      end
      return total_ins, total_del, results
    end

    # Pass an empty array for parents if the commit should have no parents
    def self.new_with_tree(repository, tree, message, actor, parents = nil)
      repository = RJGit.repository_type(repository)
      parents = parents ? parents : repository.resolve("refs/heads/#{Constants::MASTER}")
      new_commit = RJGit::Plumbing::Index.new(repository).do_commit(message, actor, parents, tree)
      Commit.new(repository, RevWalk.new(repository).parseCommit(new_commit))
    end
    
    def self.find_head(repository)
      repository = RJGit.repository_type(repository)
      return nil if repository.nil?
      begin
        walk = RevWalk.new(repository)
        objhead = repository.resolve(Constants::HEAD)
        return Commit.new(repository, walk.parseCommit(objhead))
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
        commits = walk.map { |commit| Commit.new(repository, commit) }
        return commits.first(options[:limit])
      rescue NativeException => e
        return Array.new
      end
    end
  
    def self.diff(repo, a, b = nil, paths = [], options = {})
    end

  end
end
