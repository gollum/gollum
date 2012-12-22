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

    def tag(name, message = "", commit_or_revision = nil, actor = nil, force = false)
      tag_command = @jgit.tag
      tag_command.set_name(name)
      tag_command.set_force_update(force)
      tag_command.set_message(message)
      tag_command.set_object_id(commit_or_revision) if commit_or_revision
      if actor
        actor = RJGit.actor_type(actor)
        tag_command.set_tagger(actor)
      end
      tag_command.call
    end

    def resolve_tag(tagref)
      begin
        walk = RevWalk.new(@jrepo)
        walk.parse_tag(tagref.get_object_id)
      rescue Java::OrgEclipseJgitErrors::IncorrectObjectTypeException
        nil
      end
    end
    
    def create_branch(name)
      @jgit.branch_create.setName(name).call
    end
    
    def delete_branch(name)
      @jgit.branch_delete.set_branch_names(name).call
    end
    
    def rename_branch(old_name, new_name)
      @jgit.branch_rename.set_old_name(old_name).set_new_name(new_name).call
    end
    
    def checkout(branch_name, options = {})
      checkout_command = @jgit.checkout.set_name(branch_name)
      checkout_command.set_create_branch(true) if options[:create]
      checkout_command.set_force(true) if options[:force]
      result = {}
      begin
        checkout_command.call
        result[:success] = true
        result[:result] = @jgit.get_repository.get_full_branch
      rescue Java::OrgEclipseJgitApiErrors::CheckoutConflictException => conflict
        result[:success] = false
        result[:result] = conflict.get_conflicting_paths
      end
      result
    end
    
    def apply(input_stream)
      apply_result = @jgit.apply.set_patch(input_stream).call
      updated_files = apply_result.get_updated_files 
      updated_files_parsed = []
      updated_files.each do |file|
        updated_files_parsed << file.get_absolute_path
      end
      updated_files_parsed
    end

    def apply_patch(patch_content)
      input_stream = ByteArrayInputStream.new(patch_content.to_java_bytes)
      apply(input_stream)
    end

    def apply_file(patch_file)
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