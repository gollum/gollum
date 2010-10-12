module Gollum
  class GitAccess
    attr_reader :path
    attr_reader :repo

    # Gets a Hash cache of refs to commit SHAs.
    #
    #   {"master" => "abc123", ...}
    #
    # Returns the Hash cache.
    attr_reader :ref_map

    # Gets a Hash cache of commit SHAs to a recursive tree of blobs.
    #
    #   {"abc123" => [["lib/foo.rb", "blob-sha"], [file, sha], ...], ...}
    #
    # Returns the Hash cache.
    attr_reader :tree_map
    attr_reader :commit_map

    def initialize(path)
      @path = path
      @repo = Grit::Repo.new(path)
      clear
    end

    def clear
      @ref_map    = {}
      @tree_map   = {}
      @commit_map = {}
    end

    def refresh
      @ref_map.clear
    end

    def exist?
      @repo.git.exist?
    end

    def ref_to_sha(ref)
      if sha?(ref)
        ref
      else
        get_cache(:ref, ref) { ref_to_sha!(ref) }
      end
    end

    def tree(ref)
      sha = ref_to_sha(ref)
      get_cache(:tree, sha) { tree!(sha) }
    end

    def blob(sha)
      cat_file!(sha)
    end

    def commit(ref)
      if sha?(ref)
        get_cache(:commit, ref) { commit!(ref) }
      else
        if sha = get_cache(:ref, ref)
          commit(sha)
        else
          cm = commit!(ref)
          set_cache(:ref,    ref,   cm.id)
          set_cache(:commit, cm.id, cm)
        end
      end
    end

    def commits(*shas)
      shas.flatten!
      cached_commits = multi_get(:commit, shas)
      missing_shas   = shas.select do |sha|
        !cached_commits.key?(sha)
      end

      multi_commit!(missing_shas, cached_commits) if !missing_shas.empty?

      shas.map { |sha| cached_commits[sha] }
    end

    def multi_commit!(shas, hash)
      shas.each_slice(500) do |slice|
        @repo.batch(slice).each do |commit|
          hash[commit.id] = commit
        end
      end
    end

    def sha?(str)
      str =~ /^[0-9a-f]{40}$/
    end

    def ref_to_sha!(ref)
      @repo.git.rev_list({:max_count=>1}, ref)
    end

    def tree!(sha)
      tree  = @repo.git.native(:ls_tree, 
        {:r => true, :l => true, :z => true}, sha)
      tree.split("\0").inject([]) do |items, line|
        items << parse_tree_line(line)
      end
    end

    def cat_file!(sha)
      @repo.git.cat_file({:p => true}, sha)
    end

    def commit!(sha)
      @repo.commit(sha)
    end

    def get_cache(name, key)
      cache = instance_variable_get("@#{name}_map")
      value = cache[key]
      if value.nil? && block_given?
        set_cache(name, key, value = yield)
      end
      value
    end

    def set_cache(name, key, value)
      cache      = instance_variable_get("@#{name}_map")
      cache[key] = value
    end

    def multi_get(name, keys)
      value = instance_variable_get("@#{name}_map")
      keys.inject({}) do |memo, key|
        if v = value[key]
          memo[key] = v
        end
        memo
      end
    end

    # Parses a line of output from the `ls-tree` command.
    #
    # line - A String line of output:
    #          "100644 blob 839c2291b30495b9a882c17d08254d3c90d8fb53	Home.md"
    #
    # Returns an Array of BlobEntry instances.
    def parse_tree_line(line)
      mode, type, sha, size, *name = line.split(/\s+/)
      BlobEntry.new(sha, name.to_s, size.to_i)
    end

    # Decode octal sequences (\NNN) in tree path names.
    #
    # path - String path name.
    #
    # Returns a decoded String.
    def decode_git_path(path)
      if path[0] == ?" && path[-1] == ?"
        path = path[1...-1]
        path.gsub!(/\\\d{3}/)   { |m| m[1..-1].to_i(8).chr }
      end
      path.gsub!(/\\[rn"\\]/) { |m| eval(%("#{m.to_s}")) }
      path
    end
  end
end