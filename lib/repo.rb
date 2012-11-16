module RJGit

  import 'org.eclipse.jgit.lib.Repository'
  import 'org.eclipse.jgit.lib.RepositoryBuilder'
  import 'org.eclipse.jgit.storage.file.FileRepository'
  import 'org.eclipse.jgit.treewalk.TreeWalk'
  import 'org.eclipse.jgit.treewalk.filter.PathFilter'
  import 'org.eclipse.jgit.lib.Constants'

  class Repo

    attr_accessor :git
    attr_accessor :repo
    attr_accessor :path

    TREE_TYPE = 0040000
    SYMLINK_TYPE = 0120000
    FILE_TYPE = 0100000
    GITLINK_TYPE = 0160000
    MISSING_TYPE = 0000000
    REG_FILE_TYPE = 100644

    def initialize(path, options = {}, create = false)
      epath = File.expand_path(path)

      bare = false
      if File.exist?(File.join(epath, '/.git'))
        bare = false
      elsif File.exist?(epath) || options[:bare]
        bare = true
      end

      @path = bare ? epath : File.join(epath, '/.git')

      repo_path = java.io.File.new(@path)
      @repo = bare ? RepositoryBuilder.new().set_bare.set_git_dir(repo_path).build() : RepositoryBuilder.new().set_git_dir(repo_path).build()
      @repo.create(bare) if create
      @git = RubyGit.new(@repo)
    end

    def bare?
      @repo.is_bare
    end

    def self.create(path, options = {:bare => true})
      Repo.new(path, options, true)
    end

    def commits(ref="master", limit=100)
      options = { :limit => limit }
      Commit.find_all(@repo, ref, options)
    end

    def branch
      @repo.get_full_branch
    end

    def branches
      return @git.branch_list
    end

    def add(fpattern)
      @git.add(fpattern)
    end

    # Convenience method to retrieve a Blob by name
    def blob(file_path)
      lastCommitHash = @repo.resolve(Constants::HEAD)
      return nil if lastCommitHash.nil?

      walk = RevWalk.new(@repo)
      commit = walk.parseCommit(lastCommitHash)
      treeWalk = TreeWalk.new(@repo)
      treeWalk.addTree(commit.getTree)
      treeWalk.setRecursive(true)
      treeWalk.setFilter(PathFilter.create(file_path))
      if treeWalk.next
        revBlob = walk.lookupBlob(treeWalk.objectId(0));
        revBlob.nil? ? nil : Blob.new(@repo, revBlob)
      else
        nil
      end
    end

    # Convenience method to retrieve a Tree by name
    def tree(name)
    end

  end

end
