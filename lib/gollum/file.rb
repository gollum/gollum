# ~*~ encoding: utf-8 ~*~
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

    # Public: The url path required to reach this page within the repo.
    #
    # Returns the String url_path
    def url_path
      path = self.path
      path = path.sub(/\/[^\/]+$/, '/') if path.include?('/')
      path
    end

    # Public: The url_path, but CGI escaped.
    #
    # Returns the String url_path
    def escaped_url_path
      CGI.escape(self.url_path).gsub('%2F','/')
    end

    # Public: The on-disk filename of the file.
    #
    # Returns the String name.
    def name
      @blob && @blob.name
    end
    alias filename name

    # Public: The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      @blob && @blob.data
    end

    # Public: The Grit::Commit version of the file.
    attr_accessor :version

    # Public: The String path of the file.
    attr_reader :path

    # Public: The String mime type of the file.
    def mime_type
      @blob.mime_type
    end

    # Populate the File with information from the Blob.
    #
    # blob - The Grit::Blob that contains the info.
    # path - The String directory path of the file.
    #
    # Returns the populated Gollum::File.
    def populate(blob, path=nil)
      @blob = blob
      @path = "#{path}/#{blob.name}"[1..-1]
      self
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
      if entry = map.detect { |entry| entry.path.downcase == checked }
        @path    = name
        @blob    = entry.blob(@wiki.repo)
        @version = version.is_a?(Grit::Commit) ? version : @wiki.commit_for(version)
        self
      end
    end
  end
end
