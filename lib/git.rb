module RJGit

  import 'java.io.ByteArrayInputStream'
  import 'java.io.FileInputStream'

  import 'org.eclipse.jgit.api.Git'
  import 'org.eclipse.jgit.api.AddCommand'

  
  class RubyGit
    
    attr_accessor :git
    attr_accessor :repo

    RJGit.delegate_to(Git, :@git)
      
    def initialize(repository) 
      @repo = repository
      @git = Git.new(repository)
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
      @git.commit.set_message(message).call
    end
    
    def clone(remote, local)
      Git.clone_repository.setURI(remote).set_directory(new File(local)).call
    end

    def add(file_pattern)
      @git.add.add_filepattern(file_pattern).call
    end

    def tag(name, message = "", force = false)
      Ref.new(@git.tag.set_name(name).set_force_update(force).set_message(message).call)
    end

    def tag(name, commit_or_revision_id, message = "", force = false)
      Ref.new(@git.tag.set_name(name).set_force_update(force).set_message(message).set_object_id(commit_or_revision_id).call)
    end

    def apply(input_stream)
      updated_files = @git.apply.set_patch(input_stream).call
      updated_files_parsed = []
      updated_files.each do |file|
        updated_files_parsed << file.get_absolute_path
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