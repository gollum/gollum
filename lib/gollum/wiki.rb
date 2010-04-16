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
    # name    - The human or canonical String page name of the wiki page.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::Page or nil if no matching page was found.
    def page(name, version = 'master')
      Page.new(self).find(name, version)
    end

    # Get the static file for a given name.
    #
    # name    - The full String pathname to the file.
    # version - The String version ID to find (default: "master").
    #
    # Returns a Gollum::File or nil if no matching file was found.
    def file(name, version = 'master')
      File.new(self).find(name, version)
    end

    # Write a new version of a page to the Gollum repo root.
    #
    # name   - The String name of the page.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :author  - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def write_page(name, format, data, commit = {})
      ext = Page.format_to_ext(format)
      path = Gollum.canonical_name(name) + '.' + ext
      index = self.repo.index
      index.add(path, data)
      actor = Grit::Actor.new(commit[:name], commit[:email])
      parent = self.repo.commit('master')
      index.commit(commit[:message], [parent], actor)
    end
  end
end