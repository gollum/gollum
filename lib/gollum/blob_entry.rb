module Gollum
  class BlobEntry
    # Gets the String SHA for this blob.
    attr_reader :sha

    # Gets the String full path for this blob.
    attr_reader :path

    def initialize(sha, path)
      @sha  = sha
      @path = path
      @dir = @name = @blob = nil
    end

    # Gets the normalized directory path for this blob.
    def dir
      @dir ||= self.class.normalize_dir(::File.dirname(@path))
    end

    # Gets the String file base name for this blob.
    def name
      @name ||= ::File.basename(@path)
    end

    # Gets a Grit::Blob instance for this blob.
    #
    # repo - Grit::Repo instance for the Grit::Blob.
    #
    # Returns an unbaked Grit::Blob instance.
    def blob(repo)
      @blob ||= Grit::Blob.create(repo, :id => @sha, :name => @name)
    end

    # Gets a Page instance for this blob.
    #
    # wiki - Gollum::Wiki instance for the Gollum::Page
    #
    # Returns a Gollum::Page instance.
    def page(wiki, commit)
      blob = self.blob(wiki.repo)
      page = wiki.page_class.new(wiki).populate(blob, self.dir)
      page.version = commit
      page
    end

    def inspect
      %(#<Gollum::BlobEntry #{@sha} #{@path}>)
    end

    # Normalizes a given directory name for searching through tree paths.
    # Ensures that a directory begins with a slash, or 
    #
    #   normalize_dir("")      # => ""
    #   normalize_dir(".")     # => ""
    #   normalize_dir("foo")   # => "/foo"
    #   normalize_dir("/foo/") # => "/foo"
    #   normalize_dir("/")     # => ""
    #
    # dir - String directory name.
    #
    # Returns a normalized String directory name, or nil if no directory 
    # is given.
    def self.normalize_dir(dir)
      if dir
        dir = ::File.expand_path(dir, '/')
        dir = '' if dir == '/'
      end
      dir
    end
  end
end