module Gollum
  class File
    # Public: Initialize a file.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::File.
    def initialize(wiki)
      @wiki = wiki
      @blob = nil
    end

    # Public: The on-disk filename of the file.
    #
    # Returns the String name.
    def name
      @blob && @blob.name
    end

    # Public: The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      @blob && @blob.data
    end

    # Public: The Grit::Commit version of the file.
    attr_reader :version

    #########################################################################
    #
    # Internal Methods
    #
    #########################################################################

    # Find a file in the given Gollum repo.
    #
    # name    - The full String path.
    # version - The String version ID to find.
    #
    # Returns a Gollum::File or nil if the file could not be found.
    def find(name, version)
      commit = @wiki.repo.commit(version)
      if blob = commit.tree / name
        @blob = blob
        @version = commit
        self
      else
        nil
      end
    end
  end
end