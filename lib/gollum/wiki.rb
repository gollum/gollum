module Gollum
  class Wiki
    # Initialize a new Gollum Repo.
    #
    # repo - The String path to the Git repository that holds the Gollum site.
    #
    # Returns a fresh Gollum::Repo.
    def initialize(path)
      @path = path
      @repo = Grit::Repo.new(path)
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
      index = @repo.index
      index.add(path, data)
      actor = Grit::Actor.new(commit[:name], commit[:email])
      parent = @repo.commit('master')
      index.commit(commit[:message], [parent], actor)
    end

    # Update an existing page with new content. The location of the page
    # inside the repository and the page's format will not change.
    #
    # page   - The Gollum::Page to update.
    # data   - The new String contents of the page.
    # commit - The commit Hash details:
    #          :message - The String commit message.
    #          :author  - The String author full name.
    #          :email   - The String email address.
    #
    # Returns the String SHA1 of the newly written version.
    def update_page(page, data, commit = {})
      index = @repo.index
      index.add(page.path, data)
      actor = Grit::Actor.new(commit[:name], commit[:email])
      parent = @repo.commit('master')
      index.commit(commit[:message], [parent], actor)
    end

    #########################################################################
    #
    # Private
    #
    #########################################################################

    # Private: The Grit::Repo associated with this wiki.
    attr_reader :repo

    # Private: The String path to the Git repository that holds the Gollum
    # site.
    attr_reader :path
  end
end