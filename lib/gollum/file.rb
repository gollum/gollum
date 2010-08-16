module Gollum
  class File
    Wiki.file_class = self

    # Public: Initialize a file.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::File.
    def initialize(wiki)
      @wiki = wiki
      @blob = nil
      @path = nil
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

    # Public: The String path of the file.
    attr_reader :path

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
      if commit = @wiki.repo.commit(version)
        if (blob = commit.tree / name) && blob.is_a?(Grit::Blob)
          @blob    = blob
          @path    = name
          @version = commit
          self
        end
      end
    end
  end
end