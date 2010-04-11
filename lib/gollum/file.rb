module Gollum
  class File
    attr_accessor :wiki, :blob, :version

    # Initialize a file.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::File.
    def initialize(wiki)
      self.wiki = wiki
    end

    # The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      self.blob.data rescue nil
    end

    # Find a file in the given Gollum repo.
    #
    # name    - The full String path.
    # version - The String version ID to find.
    #
    # Returns a Gollum::File or nil if the file could not be found.
    def find(name, version)
      commit = self.wiki.repo.commit(version)
      if blob = commit.tree / name
        self.blob = blob
        self.version = commit
        self
      else
        nil
      end
    end
  end
end