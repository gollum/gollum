module Gollum
  class GitAccess
    attr_reader :path
    attr_reader :repo
    attr_reader :ref_map
    attr_reader :tree_map

    def initialize(path)
      @path     = path
      @repo     = Grit::Repo.new(path)
      @ref_map  = {}
      @tree_map = {}
    end

    def exist?
      @repo.git.exist?
    end
  end
end