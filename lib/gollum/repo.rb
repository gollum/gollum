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

    # Get the formatted page for a given page name.
    #
    # name - The String name of the wiki page.
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def formatted_page(name)
      Page.new()
    end
  end
end