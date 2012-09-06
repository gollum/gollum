module RJGit

  import 'org.eclipse.jgit.revwalk.RevWalk'
  import 'org.eclipse.jgit.revwalk.RevCommit'

  class Commit

    attr_reader :id
    attr_reader :repo
    attr_reader :parents
    attr_reader :tree
    attr_reader :author
    attr_reader :authored_date
    attr_reader :committer
    attr_reader :committed_date
    attr_reader :message
    attr_reader :short_message
  
    def initialize(commit)
      # @repo = repo
      @id = commit.get_id
      # @parents = parents.map { |p| Commit.create(repo, :id => p) }
      # @tree = Tree.create(repo, :id => tree)
      @author = commit.author_ident
      # @authored_date = authored_date
      # @committer = committer
      @committed_date = Time.at(commit.commit_time)
      @message = commit.full_message
      @short_message = commit.full_message.split("\n").select { |x| !x.strip.empty? }[0] || ''
    end
  
    def self.find_all(repo, ref, options)
      begin
        walk = RevWalk.new(repo);
        objHead = repo.resolve(ref)
        root = walk.parse_commit(objHead)
        walk.mark_start(root)
        commits = walk.map { |commit| Commit.new(commit) }
        return commits.first(options[:limit])
      rescue NativeException => e
        return Array.new
      end
    end
  
    def self.diff(repo, a, b = nil, paths = [], options = {})
    end
    
    def show
    end
    
    def inspect
      %Q{#<Git4j::Commit "#{@id}">}
    end    
    
  end

end