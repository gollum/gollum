module Gollum
  class Version
    attr_accessor :commit

    def initialize(commit)
      self.commit = commit
    end

    # The SHA1 commit ID.
    #
    # The String ID.
    def id
      self.commit.id
    end
  end
end