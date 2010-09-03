module Gollum
  class TreeCache 

    def initialize(repo)
      @repo = repo
      clear
    end
    
    # Clears the ref and tree maps.
    #
    # Returns nothing.
    def clear
      @ref_map = {}
      @tree_map = {}
    end

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

    # Finds a full listing of files and their blob SHA for a given ref.  Each
    # listing is cached based on its actual commit SHA.
    #
    # ref - A String ref that is either a commit SHA or references one.
    #
    # Returns an Array of BlobEntry instances.
    def tree_for(ref)
      sha = @ref_map[ref] || ref
      @tree_map[sha] || begin
        real_sha              = @repo.git.rev_list({:max_count=>1}, ref)
        @ref_map[ref]         = real_sha if real_sha != ref
        @tree_map[real_sha] ||= parse_tree_for(real_sha)
      end
    end

    # Finds the full listing of files and their blob SHA for a given commit
    # SHA.  No caching or ref lookups are performed.
    #
    # sha - String commit SHA.
    #
    # Returns an Array of BlobEntry instances.
    def parse_tree_for(sha)
      tree  = @repo.git.native(:ls_tree, {:r => true, :z => true}, sha)
      items = []
      tree.split("\0").each do |line|
        items << parse_tree_line(line)
      end
      items
    end

    # Parses a line of output from the `ls-tree` command.
    #
    # line - A String line of output:
    #          "100644 blob 839c2291b30495b9a882c17d08254d3c90d8fb53	Home.md"
    #
    # Returns an Array of BlobEntry instances.
    def parse_tree_line(line)
      data, name = line.split("\t")
      mode, type, sha = data.split(' ')
      name = decode_git_path(name)
      BlobEntry.new sha, name
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

    # Load a set of trees into the cache.
    #
    # refs - Array of ref names to pre-fetch
    #
    # Returns nothing.
    def prefetch(refs)
      refs = [refs] if refs.kind_of?(String)
      refs && refs.each { |ref| tree_for(ref) }
    end
  end
end
