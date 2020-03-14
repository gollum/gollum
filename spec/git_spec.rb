require 'spec_helper'
require 'git_spec/dummy_ssh_transport'

describe RubyGit do

  it "returns a status object" do
    repo = Repo.new(TEST_REPO_PATH)
    expect(repo.git.status.get_modified.to_a).to be_empty
    expect(repo.git.status.is_clean).to be true
  end

  context "when logging" do
    it "returns log information" do
      repo = Repo.new(TEST_REPO_PATH)
      messages = repo.git.log
      expect(messages).to_not be_empty
      expect(messages.first.message).to match /Renamed the follow rename file/
      messages = repo.git.log("deconstructions.txt")
      expect(messages.first.message).to match /More interesting postmodern comments./
      messages = repo.git.log(nil, "HEAD", {max_count: 1})
      expect(messages.count).to eq 1
      messages = repo.git.log(nil, "HEAD", {max_count: 1, skip: 1})
      expect(messages.first.message).to_not match /More interesting postmodern comments./
    end

    it "returns log information for an array of refs" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      expect(ids).to have(8).ids
      logs = repo.git.logs(ids, max_count: 1)
      expect(logs).to have(8).logs
      first_log = logs.first
      expect(first_log).to have(1).logs
      expect(first_log.first.message).to match /Renamed the follow rename file/
    end

    it "returns log information for a range of commits" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      logs = repo.git.log(nil, "HEAD", since: '83fc72f692a717cfffd77b32f705c4063357e6a6', until: '55ca9d4360c522d38bc73ef9cce81c2f72c413d5')
      expect(logs).to have(1).logs
      expect(logs.first.message).to match /Renamed the follow rename file/
    end

    it "returns log information excluding certain refs" do
      repo = Repo.new(TEST_REPO_PATH)
      ids = repo.commits.map(&:id)
      logs = repo.git.log(nil, "HEAD", not: ['ad982fe7d4787928daba69bf0ba44a59c572ccd7'])
      expect(logs).to have(7).logs
      expect(logs.map(&:id)).to_not include 'ad982fe7d4787928daba69bf0ba44a59c572ccd7'
    end

    it "follows renames for specific path" do
      repo = Repo.new(TEST_REPO_PATH)
      commits = repo.git.log("follow-rename.txt", "HEAD", follow: true, list_renames: true)
      expect(commits[0]).to be_a TrackingCommit
      expect(commits[0].tracked_pathname).to eq 'follow-rename.txt'
      expect(commits[1].tracked_pathname).to eq 'rename-example.txt'
      expect(commits.count).to eq 2
      expect(commits[1].message).to match /for following renames/
    end

  end

  context "when creating tags" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end

    it "tag with only a name" do
      expect(@repo.tags).to have(0).tags
      @repo.git.tag('v0.0')
      expect(@repo.tags).to have_exactly(1).tags
    end

    it "tag with a name and message" do
      expect(@repo.tags).to have(0).tags
      @repo.git.tag('v0.0', 'initial state commit')
      expect(@repo.tags).to have_exactly(1).tags
      expect(@repo.tags['v0.0'].full_message).to match /initial state commit/
    end

    it "tag with a specific commit or revision" do
      commit = @repo.commits.first
      @repo.git.tag('v0.0', 'initial state commit for a specific commit', commit)
      expect(@repo.tags).to have_exactly(1).tags
    end

    it "tag with specific actor information" do
      actor = Actor.new('Rspec Examplar', 'rspec@tagging.example')
      @repo.git.tag('v0.0', 'initial state commit', nil, actor)
      expect(@repo.tags).to have_exactly(1).tags
      expect(@repo.tags["v0.0"].actor.name).to eq 'Rspec Examplar'
    end

    after(:each) do
      remove_temp_repo(@temp_repo_path)
      @repo = nil
    end
  end

  context "committing with settings" do

    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      @git = @repo.git
      @actor = Actor.new('Rspec Examplar', 'rspec@tagging.example')
    end

    it "commits files with all jgit settings" do
      File.open(File.join(@temp_repo_path, "rspec-committest.txt"), 'w') {|file| file.write("This file is for comitting.")}
      @repo.add("rspec-comittest.txt")
      options = {all: false, amend: false, author: @actor, committer: @actor, insert_change_id: false, only_paths: ["rspec-comittest.txt"], reflog_comment: "test"}
      [:set_all, :set_amend, :set_author, :set_committer, :set_insert_change_id, :set_only, :set_reflog_comment].each {|message| expect_any_instance_of(org.eclipse.jgit.api.CommitCommand).to receive(message)}
      commit = @git.commit("Creating a commit for testing jgit setters", options)
    end

     after(:each) do
      remove_temp_repo(@temp_repo_path)
    end

  end

  context "when merging" do

    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
      @repo.create_branch('branch_for_merging')
      @repo.checkout('branch_for_merging')
    end

    it "merges a commit with current branch" do
      # add and commit new file to new branch
      File.open(File.join(@temp_repo_path, "rspec-mergetest.txt"), 'w') {|file| file.write("This file is for merging.")}
      @repo.add("rspec-mergetest.txt")
      commit = @repo.commit("Creating a commit for merging")
      # change to 'master' branch
      @repo.checkout('master')
      # merge commit from branch with 'master'
      @repo.git.merge(commit)
      # check for successful merge
      listing = RJGit::Porcelain.ls_tree(@repo)
      listing.select! {|entry| entry[:path] == "rspec-mergetest.txt" }
      expect(listing).to have(1).entry
    end

    it "returns an Array with conflict names when there are conflicts" do
      File.open(File.join(@temp_repo_path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
      @repo.add("materialist.txt")
      commit = @repo.commit("Creating a conflict - step 1")
      @repo.checkout('master')
      File.open(File.join(@temp_repo_path, "materialist.txt"), 'a') {|file| file.write("\n Same line - different string.") }
      @repo.add("materialist.txt")
      @repo.commit("Creating a conflict - step 2")
      result = @repo.git.merge(commit)
      expect(result).to include('materialist.txt')
    end

    after(:each) do
      remove_temp_repo(@temp_repo_path)
    end

  end

  context "cloning a non-bare repository" do
    before(:each) do
      @repo = Repo.new(TEST_REPO_PATH)
      @remote = TEST_REPO_PATH
      @local  = get_new_temp_repo_path
    end

    it "creates a new local repository" do
      clone = @repo.git.clone(@remote, @local)
      expect(clone.path).to eq File.join(@local, '/.git')
      expect(File.exist?(File.join(@local, 'homer-excited.png'))).to be true
    end

    it "clones a specific branch if specified" do
      clone = @repo.git.clone(@remote, @local, {branch: 'refs/heads/alternative'})
      expect(clone.branches).to have_exactly(1).branch
      expect(clone.branches.first).to eq 'refs/heads/alternative'
    end

    it "clones all branches if specified" do
      clone = @repo.git.clone(@remote, @local, {branch: :all})
      expect(clone.branches).to have_at_least(1).branch

      skip "This specs fails because of a JGit bug with CloneCommand#set_clone_all_branches(true)"
    end

    it "clones with credentials" do
      clone = @repo.git.clone(@remote, @local, username: 'rspec', password: 'Hahmeid7')
      expect(clone.path).to eq File.join(@local, '/.git')
      expect(File.exist?(File.join(@local, 'homer-excited.png'))).to be true
    end

    after(:each) do
      remove_temp_repo(@local)
    end
  end

  context "setting the transport with set_command_transport" do
    let(:clone_command) { instance_double("CloneCommand") }

    it "calls RJGitSSHConfigCallback for an ssh URI" do
      remote_with_ssh = "ssh:gitserver.zzz:gituser/gitrepo.git"
      expect(clone_command).to receive(:set_transport_config_callback).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_credentials_provider)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_ssh)
    end

    it "calls RJGitSSHConfigCallback for options[:transport_protocol] == :ssh" do
      remote_without_ssh = "git@gitserver.zzz:gituser/gitrepo.git"
      options = {transport_protocol: :ssh}
      expect(clone_command).to receive(:set_transport_config_callback).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_credentials_provider)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_without_ssh, options)
    end

    it "makes no call for an ssh-like URI and options[:transport_protocol] != :ssh" do
      remote_without_ssh = "gitserver.zzz:gituser/gitrepo.git"
      options = {}
      expect(clone_command).to_not receive(:set_transport_config_callback)
      expect(clone_command).to_not receive(:set_credentials_provider)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_without_ssh, options)
    end

    it "makes no call for an ssh-with-user-like URI and options[:transport_protocol] != :ssh" do
      remote_without_ssh = "git@gitserver.zzz:gituser/gitrepo.git"
      options = {}
      expect(clone_command).to_not receive(:set_transport_config_callback)
      expect(clone_command).to_not receive(:set_credentials_provider)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_without_ssh, options)
    end

    it "calls RJGitSSHConfigCallback for options[:private_key_file] == 'something'" do
      remote_without_ssh = "git@gitserver.zzz:gituser/gitrepo.git"
      options = {private_key_file: 'something'}
      expect(clone_command).to receive(:set_transport_config_callback).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_credentials_provider)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_without_ssh, options)
    end

    it "calls set_credentials_provider for http URI" do
      remote_with_http = "http://gitserver.zzz/gituser/gitrepo.git"
      expect(clone_command).to receive(:set_credentials_provider).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_http)
    end

    it "calls set_credentials_provider for https URI" do
      remote_with_https = "https://gitserver.zzz/gituser/gitrepo.git"
      expect(clone_command).to receive(:set_credentials_provider).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_https)
    end

    it "calls set_credentials_provider for options[:username] == 'something'" do
      remote_with_dir = "/tmp/gitserver.zzz/gituser/gitrepo.git"
      options = {username: 'something'}
      expect(clone_command).to receive(:set_credentials_provider).with(anything).and_return(true)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_dir, options)
    end

    it "makes no call for file transport without options[:username] set" do
      remote_with_dir = "file:/tmp/gitserver.zzz/gituser/gitrepo.git"
      expect(clone_command).to_not receive(:set_credentials_provider)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_dir)
    end

    it "makes no call for unknown transport without options[:username] set" do
      remote_with_dir = "unknown:/tmp/gitserver.zzz/gituser/gitrepo.git"
      expect(clone_command).to_not receive(:set_credentials_provider)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_dir)
    end

    it "makes no call for no transport needed" do
      remote_with_dir = "/tmp/gitserver.zzz/gituser/gitrepo.git"
      expect(clone_command).to_not receive(:set_credentials_provider)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_with_dir)
    end

    it "makes no call based on a bad URI " do
      remote_bad_uri = "<>"
      expect(clone_command).to_not receive(:set_credentials_provider)
      expect(clone_command).to_not receive(:set_transport_config_callback)
      ::RJGit::RubyGit.set_command_transport(clone_command, remote_bad_uri)
    end
  end

  context "configuring an ssh callback using RJGitSSHConfigCallback" do
    let(:dummy_session) {instance_double("Session")}
    let(:dummy_ssh_transport) { DummySSHTransport.new }
    let(:fs) { instance_double("FS")}
    let(:dummy_j_sch) { instance_double("JSch") }
    def create_dummy_session(options)
      #initialize the config callback
      ssh_config_callback = ::RJGit::RubyGit::RJGitSSHConfigCallback.new(options)
      #configure the config callback
      ssh_config_callback.configure(dummy_ssh_transport)
      #get the ssh session factory
      dummy_ssh_session_factory = dummy_ssh_transport.dummy_factory
      #configure the ssh session factory
      dummy_ssh_session_factory.configure("some_host", dummy_session)
      #create the jsch using the factory
      dummy_ssh_session_factory.createDefaultJSch(fs)
    end

    it "configures for ssh default behavior when no specifics given" do
      options = {}
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to_not receive(:setUserName)
      expect(dummy_session).to_not receive(:setPassword)
      expect(dummy_j_sch).to_not receive(:removeAllIdentity)
      expect(dummy_j_sch).to_not receive(:addIdentity)
      expect(dummy_j_sch).to_not receive(:setKnownHosts)

      create_dummy_session(options)
    end

    it "configures for a specific known hosts file if options[:known_hosts_file]" do
      options = {known_hosts_file: 'aknownhostsfile'}
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to_not receive(:setUserName)
      expect(dummy_session).to_not receive(:setPassword)
      expect(dummy_j_sch).to_not receive(:removeAllIdentity)
      expect(dummy_j_sch).to_not receive(:addIdentity)
      expect(dummy_j_sch).to receive(:setKnownHosts).with(options[:known_hosts_file]).and_return(true)

      create_dummy_session(options)
    end

    it "configures for a specific private key file if options[:private_key_file]" do
      options = {private_key_file: 'aprivatekeyfile'}
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to_not receive(:setUserName)
      expect(dummy_session).to_not receive(:setPassword)
      expect(dummy_j_sch).to receive(:removeAllIdentity).with(no_args).and_return(true)
      expect(dummy_j_sch).to receive(:addIdentity).with(options[:private_key_file]).and_return(true)
      expect(dummy_j_sch).to_not receive(:setKnownHosts)

      create_dummy_session(options)
    end

    it "configures for a specific encrypted private key file if options[:private_key_file] and options[:priavte_key_passphrase]" do
      options = {private_key_file: 'something', private_key_passphrase: 'another_thing'}
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to_not receive(:setUserName)
      expect(dummy_session).to_not receive(:setPassword)
      expect(dummy_j_sch).to receive(:removeAllIdentity).with(no_args)
      expect(dummy_j_sch).to receive(:addIdentity).with(options[:private_key_file], options[:private_key_passphrase]).and_return(true)
      expect(dummy_j_sch).to_not receive(:setKnownHosts)

      create_dummy_session(options)
    end

    it "configures for ssh username if options[:username]" do
      options = {username: 'gituser'}
      allow(dummy_session).to receive(:setUserName)
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to receive(:setUserName).with(options[:username])
      expect(dummy_session).to_not receive(:setPassword)
      expect(dummy_j_sch).to_not receive(:removeAllIdentity)
      expect(dummy_j_sch).to_not receive(:addIdentity)
      expect(dummy_j_sch).to_not receive(:setKnownHosts)

      create_dummy_session(options)
    end

    it "configures for ssh password if options[:password]" do
      options = {password: 'something'}
      allow(dummy_session).to receive(:setUserName)
      allow_any_instance_of(::Java::OrgEclipseJgitTransport.JschConfigSessionFactory).to receive(:createDefaultJSch).and_return(dummy_j_sch)
      expect(dummy_session).to_not receive(:setUserName)
      expect(dummy_session).to receive(:setPassword).with(options[:password])
      expect(dummy_j_sch).to_not receive(:removeAllIdentity)
      expect(dummy_j_sch).to_not receive(:addIdentity)
      expect(dummy_j_sch).to_not receive(:setKnownHosts)

      create_dummy_session(options)
    end
  end

  context "cloning an ssh repository" do
    before(:each) do
      @local  = get_new_temp_repo_path
    end

    it "calls set_command_transport for URI with ssh" do
      clone_command = instance_double("CloneCommand")

      remote_with_ssh = "ssh:gitserver.zzz:gituser/gitrepo"
      #repo = Repo.new(remote_with_ssh)

      expect(Git).to receive(:clone_repository).with(no_args).and_return(clone_command)
      expect(clone_command).to receive(:setURI).with(remote_with_ssh).and_return(true)
      expect(clone_command).to receive(:set_directory).and_return(true)
      allow(clone_command).to receive(:set_bare).and_return(true)
      allow(clone_command).to receive(:set_branch).and_return(true)
      allow(clone_command).to receive(:set_clone_all_branches).and_return(true)
      expect(::RJGit::RubyGit).to receive(:set_command_transport).with(clone_command, remote_with_ssh, anything).and_return(true)
      expect(clone_command).to receive(:call).with(no_args).and_return(true)

      ::RJGit::RubyGit.clone(remote_with_ssh, @local)
    end
  end

  context "cloning a bare repository" do
    before(:each) do
      remote = TEST_BARE_REPO_PATH
      @local  = get_new_temp_repo_path(true)
      @clone = RubyGit.clone(remote, @local, is_bare: true)
    end

    it "is be bare" do
      expect(@clone).to be_bare
    end

    after(:each) do
      remove_temp_repo(@local)
    end
  end

  context "patching" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)
    end

    it "applies a patch from a String" do
      patch = fixture('postpatriarchialist.patch')
      result = @repo.git.apply_patch(patch)
      expect(result).to have(1).changed_file
      expect(result.first).to match /postpatriarchialist.txt/
    end

    it "applies a patch from a file" do
      patch = File.join(File.dirname(__FILE__), 'fixtures', 'postpatriarchialist.patch')
      result = @repo.git.apply_file(patch)
      expect(result).to have(1).changed_file
      expect(result.first).to match /postpatriarchialist.txt/
    end

    after(:each) do
      remove_temp_repo(@temp_repo_path)
    end

  end

  describe "push, pull and fetch" do
    before(:each) do
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @remote = Repo.new(@temp_repo_path)
      @local = @remote.git.clone(@remote.path, get_new_temp_repo_path)
    end

    context "pulling from another repository" do
      before(:each) do
        File.open(File.join(@remote.path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
        @remote.add("materialist.txt")
        @commit = @remote.commit("Making a change for pushing and pulling specs")
      end

      it "pulls commits from a local clone" do
        expect(@local.commits).to have(8).commits
        @local.git.pull("origin", "master")
        expect(@local.commits).to have(9).commits
      end

      it "pulls commits from a local clone with rebase" do
        expect(@local.commits).to have(8).commits
        @local.git.pull(nil, nil, rebase: true)
        expect(@local.commits).to have(9).commits
      end

      it "pulls commits from a local clone with credentials" do
        expect(@local.commits).to have(8).commits
        @local.git.pull(nil, nil, username: 'rspec', password: 'Hahmeid7')
        expect(@local.commits).to have(9).commits
      end

    end

    context "fetching from another repository" do
      before(:each) do
        @remote.git.tag('a_new_tag')
      end

      it "fetches from a local clone" do
        expect(@local.branches).to have(1).branches
        expect(@local.tags).to have(0).tags
        @local.git.fetch(@remote.path, refspecs: "+refs/heads/*:refs/heads/*")
        # 2 branches are expected here because the remote has 2 branches, master and alternative,
        # though only one showed up locally until the fetch was done with the refspecs above.
        expect(@local.branches).to have(2).branches
        # Also fetch new tag
        @local.git.fetch(@remote.path, refspecs: "+refs/tags/*:refs/tags/*")
        expect(@local.tags).to have(1).tags
      end

      it "fetches from a local clone with credentials" do
        expect(@local.branches).to have(1).branches
        expect(@local.tags).to have(0).tags
        @local.git.fetch(@remote.path, refspecs: "+refs/heads/*:refs/heads/*", username: 'rspec', password: 'Hahmeid7')
        # 2 branches are expected here because the remote has 2 branches, master and alternative,
        # though only one showed up locally until the fetch was done with the refspecs above.
        expect(@local.branches).to have(2).branches
        # Also fetch new tag
        @local.git.fetch(@remote.path, refspecs: "+refs/tags/*:refs/tags/*")
        expect(@local.tags).to have(1).tags
      end
    end

    context "pushing to another repository" do
      let(:options) {{}}
      let(:message) { "Making a change for pushing and pulling specs" }

      before(:each) do
        File.open(File.join(@local.path, "materialist.txt"), 'a') {|file| file.write("\n Beautiful materialist.") }
        @local.add("materialist.txt")
        @commit = @local.commit(message, options)
      end

      it "pushes all changes to a local clone" do
        expect(@remote.commits).to have(8).commits
        @local.git.push_all('origin')
        expect(@remote.commits).to have(9).commits
      end

      it "pushes all changes to a local clone with credentials" do
        expect(@remote.commits).to have(8).commits
        @local.git.push_all('origin', username: 'rspec', password: 'Hahmeid7')
        expect(@remote.commits).to have(9).commits
      end

      it "pushes a specific ref to a local clone" do
        expect(@remote.commits).to have(8).commits
        @local.git.push('origin', ["master"], username: 'rspec', password: 'Hahmeid7')
        expect(@remote.commits).to have(9).commits
      end

      context "when non-fastforwardable" do
        let(:options) {{ amend: true }}

        it "pushes all with force: true" do
          expect do
            @local.git.push_all('origin', username: 'rspec', password: 'Hahmeid7', force: true)
          end.to change { @remote.head.message }.to message
        end

        it "pushes a specific ref with force: true" do
          expect do
            @local.git.push('origin', ["master"], username: 'rspec', password: 'Hahmeid7', force: true)
          end.to change { @remote.head.message }.to message
        end

        it "does not push all without force option" do
          expect do
            @local.git.push_all('origin', username: 'rspec', password: 'Hahmeid7')
          end.not_to change { @remote.head.message }
        end

        it "does not push a specific ref without force option" do
          expect do
            @local.git.push('origin', ["master"], username: 'rspec', password: 'Hahmeid7')
          end.not_to change { @remote.head.message }
        end
      end

    end

    after(:each) do
      remove_temp_repo(@temp_repo_path)
      remove_temp_repo(File.dirname(@local.path))
    end

  end

  context "cleaning a repository" do
    before(:each) do
      @temp_repo_path = get_new_temp_repo_path
      @repo = Repo.create(@temp_repo_path)
  	  File.open(File.join(@temp_repo_path, "rspec-addfile.txt"), 'w') {|file| file.write("This is a new file to add.") }
    end

    it "removes untracked files from the working tree" do
      @repo.clean
      expect(File.exist?(File.join(@temp_repo_path, "rspec-addfile.txt"))).to be false
    end

    context "after adding files" do

      before(:each) do
        @repo.add("#{@temp_repo_path}/rspec-addfile.txt")
        @entry = RJGit::Porcelain.diff(@repo).first
      end
      it "removes added files from the index" do
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean
        @entry = RJGit::Porcelain.diff(@repo).first
        expect(@entry).to be_nil
      end

      it "performs a dry run when asked" do
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
        @repo.clean(dryrun: true)
        @entry = RJGit::Porcelain.diff(@repo).first
        expect(@entry[:changetype]).to eq "ADD"
        expect(@entry[:newid]).to match "0621fdbce5ff954c0742c75076041741142b876d"
      end
    end

    after(:each) do
      @repo = nil
      remove_temp_repo(@temp_repo_path)
    end
  end

  context "resetting a (part of) a repository" do
    before(:each) do
      #Create a temporary repository
      @temp_repo_path = create_temp_repo(TEST_REPO_PATH)
      @repo = Repo.new(@temp_repo_path)

      #Open the 'materialist.txt' file in the repo and add the text "fluffy bunny"
      File.open(File.join(@temp_repo_path,"materialist.txt"), "a+") do |f|
        @before_write = f.read
        f.write("fluffy bunny")
      end
    end

    it "reverts commits" do
      @repo.add("materialist.txt")
      to_revert = @repo.commit("Added test for reverting.")
      reverted_commit = @repo.git.revert([to_revert])
      expect(@repo.commits.first.id).to eq reverted_commit.id
    end

    it "handles errors for revert"

    it "resets the hard way" do
      #reset the 'materialist.txt' file to the current head, through the HARD way
      ref = @repo.commits.first
      @repo.git.reset(ref)

      #Check if the hard reset worked correctly
      File.open(File.join(@temp_repo_path,"materialist.txt"), "r") do |f|
        expect(f.read).to eq @before_write
      end
    end

    it "unstages files" do
      paths = ["materialist.txt"]
      @repo.add("#{paths.first}")
      expect(@repo.git.status.getChanged.to_a).to include(paths.first)
      ref = @repo.commits.first
      @repo.git.reset(ref, nil, paths)
      expect(@repo.git.status.getChanged.to_a).to_not include(paths.first)
    end

    it "returns nil if mode is not valid" do
      ref = @repo.commits.first
      expect(@repo.git.reset(ref, "NONEXISTENT")).to be_nil
    end

    it "does not reset any type together with specified file paths" do
      mode = "MERGE"
      paths = ["materialist.txt"]
      ref = @repo.commits.first
      expect { @repo.git.reset(ref, mode, paths) }.to raise_error org.eclipse.jgit.api.errors.JGitInternalException
    end

    after(:each) do
      @repo = nil
      remove_temp_repo(@temp_repo_path)
    end

  end

end
