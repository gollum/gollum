module RJGit

  import 'java.io.ByteArrayInputStream'
  import 'java.io.FileInputStream'

  import 'org.eclipse.jgit.api.Git'
  import 'org.eclipse.jgit.api.AddCommand'

  class RubyGit
  
    attr_accessor :git
    attr_accessor :repo
  
    def initialize(repository)
      @repo = repository
      @git = Git.new(repository)
    end
    
    def method_missing(name, *args)
      begin
	      @git.send(name, *args)
      rescue NoMethodError
	      return super
      end
    end
  
    def log
      logs = @git.log
      commits = Array.new
      logs.call.each do |commit|
        commits << Commit.new(commit)
      end
      commits
    end
  
    def branch_list
      branch = @git.branch_list
      array = Array.new
      branch.call.each do |b|
        array << b.get_name
      end
      array
    end
    
    def commit(message)
      @git.commit.setMessage(message).call
    end
    
    def clone(remote, local)
      Git.cloneRepository().setURI(remote).setDirectory(new File(local)).call
    end

    def add(fpattern)
      @git.add.addFilePattern(fpattern).call
    end

    def tag(name, message = "", force = false)
      Ref.new(@git.tag.setName(name).setForceUpdate(force).setMessage(message).call)
    end

    def tag(name, commit_or_revision_id, message = "", force = false)
      Ref.new(@git.tag.setName(name).setForceUpdate(force).setMessage(message).setObjectId(commit_or_revision_id).call)
    end

    def apply(input_stream)
      updated_files = @git.apply.setPatch(input_stream).call
      updated_files_parsed = []
      updated_files.each do |file|
        updated_files_parsed << file.getAbsolutePath
      end
      updated_files_parsed
    end

    def applyPatch(patch_content)
      input_stream = ByteArrayInputStream.new(patch_content.to_java_bytes)
      apply(input_stream)
    end

    def applyFile(patch_file)
      input_stream = FileInputStream.new(patch_file)
      apply(input_stream)
    end

    def clean
      @git.clean.call
    end

  end

end