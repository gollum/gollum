module Gollum
  class Repo
    attr_accessor :path, :repo

    # Initialize a new Gollum Repo.
    #
    # repo - The String path to the Git repository that holds the Gollum site.
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path)
      self.path = path
      self.repo = Grit::Repo.new(path)
    end
  end
end