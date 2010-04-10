module Gollum
  class Wiki
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
    # name - The human or canonical String page name of the wiki page.
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def page(name)
      Page.new(self).find(name)
    end
  end
end