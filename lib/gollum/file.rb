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

    # Public: The String mime type of the file.
    def mime_type
      @blob.mime_type
    end

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
      checked = name.downcase
      map     = @wiki.tree_map_for(version)
      sha     = @wiki.ref_map[version] || version
      if entry = map.detect { |entry| entry.path.downcase == checked }
        @path    = name
        @blob    = Grit::Blob.create(@wiki.repo,   :id => entry.sha, :name => entry.name)
        @version = Grit::Commit.create(@wiki.repo, :id => sha)
        self
      end
    end
  end
end