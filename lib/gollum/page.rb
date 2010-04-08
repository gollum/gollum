module Gollum
  class Page
    attr_accessor :wiki, :data

    # Initialize a page.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::Page.
    def initialize(wiki)
      self.wiki = wiki
    end

    # Populate this Page with information from the Blob.
    #
    # blob - The Grit::Blob that contains the info.
    #
    # Returns the populated Gollum::Page.
    def populate(blob)
      self.data = blob.data
      self
    end

    # Find a page in the given Gollum repo.
    #
    # name - The human or canonical String page name to find.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find(name)
      commit = self.wiki.repo.commits.first
      content = find_page_in_tree(commit.tree, name)
    end

    # private

    # Find a page in a given commit.
    #
    # commit - The Grit::Commit in which to look.
    # name   - The human or canonical String page name.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find_page_in_commit(commit, name)

    end

    # Find a page in a given tree.
    #
    # tree - The Grit::Tree in which to look.
    # name - The canonical String page name.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find_page_in_tree(tree, name)
      trees = [tree]

      while !trees.empty?
        trees.shift.contents.each do |item|
          case item
            when Grit::Blob
              return populate(item) if page_match(name, item.name)
            when Grit::Tree
              trees << item
          end
        end
      end

      return nil # nothing was found
    end

    # Compare the canonicalized versions of the two names.
    #
    # name1 - A human or canonical String page name.
    # name2 - A human or canonical String page name.
    #
    # Returns a Boolean.
    def page_match(name1, name2)
      Gollum.canonical_name(name1) == Gollum.canonical_name(name2)
    end
  end
end