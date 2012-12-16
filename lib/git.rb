module RJGit

  import 'java.io.ByteArrayInputStream'
  import 'java.io.FileInputStream'

  import 'org.eclipse.jgit.api.Git'
  import 'org.eclipse.jgit.api.AddCommand'
  import 'org.eclipse.jgit.api.RmCommand'

  
  class RubyGit
    
    attr_accessor :jgit
    attr_accessor :jrepo

    RJGit.delegate_to(Git, :@jgit)
      
    def initialize(repository)
      @jrepo = RJGit.repository_type(repository)
      @jgit = Git.new(@jrepo)
    end
    
    def log
      logs = @jgit.log
      commits = Array.new
      logs.call.each do |jcommit|
        commits << Commit.new(jcommit)
      end
      commits
    end
  
    def branch_list
      branch = @jgit.branch_list
      array = Array.new
      branch.call.each do |b|
        array << b.get_name
      end
      array
    end
    
    def commit(message)
      @jgit.commit.set_message(message).call
    end
    
    def clone(remote, local, options = {})
      RubyGit.clone(remote, local, options)
    end
    
    def self.clone(remote, local, options = {})
      clone_command = Git.clone_repository
      clone_command.setURI(remote)
      clone_command.set_directory(java.io.File.new(local))
      clone_command.set_bare(true) if options[:bare]
      if options[:branch]
        if options[:branch] == :all
          clone_command.set_clone_all_branches(true)
        else
          clone_command.set_branch(options[:branch]) 
        end
      end
      clone_command.call
      Repo.new(local)
    end

    def add(file_pattern)
      @jgit.add.add_filepattern(file_pattern).call
    end
    
    def remove(file_pattern)
      @jgit.rm.add_filepattern(file_pattern).call
    end

    def tag(name, message = "", force = false)
      Ref.new(@jgit.tag.set_name(name).set_force_update(force).set_message(message).call)
    end

    def tag(name, commit_or_revision_id, message = "", force = false)
      Ref.new(@jgit.tag.set_name(name).set_force_update(force).set_message(message).set_object_id(commit_or_revision_id).call)
    end

    def apply(input_stream)
      updated_files = @jgit.apply.set_patch(input_stream).call
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

    def clean(options = {})
      clean_command = @jgit.clean
      clean_command.set_dry_run(true) if options[:dryrun]
      clean_command.set_paths(java.util.Arrays.asList(options[:paths])) if options[:paths]
      clean_command.call
    end

  end

end