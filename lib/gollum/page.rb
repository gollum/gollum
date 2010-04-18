module Gollum
  class Page
    VALID_PAGE_RE = /^(.+)\.(md|mkdn?|mdown|markdown|textile|rdoc|org|re?st(\.txt)?|asciidoc|pod|\d)$/i

    # Public: Initialize a page.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::Page.
    def initialize(wiki)
      @wiki = wiki
      @blob = nil
    end

    # Public: The on-disk filename of the page.
    #
    # Returns the String name.
    def name
      @blob.name rescue nil
    end

    # Public: The path of the page within the repo.
    #
    # Returns the String path.
    attr_reader :path

    # Public: The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      @blob.data rescue nil
    end

    # Public: The formatted contents of the page.
    #
    # Returns the String data.
    def formatted_data
      Gollum::Markup.render(@blob.name, @blob.data) rescue nil
    end

    # Public: The format of the page.
    #
    # Returns the Symbol format of the page. One of:
    #   [ :markdown | :textile | :rdoc | :org | :rest | :asciidoc | :pod |
    #     :roff ]
    def format
      case @blob.name
        when /\.(md|mkdn?|mdown|markdown)$/i
          :markdown
        when /\.(textile)$/i
          :textile
        when /\.(rdoc)$/i
          :rdoc
        when /\.(org)$/i
          :org
        when /\.(re?st(\.txt)?)$/i
          :rest
        when /\.(asciidoc)$/i
          :asciidoc
        when /\.(pod)$/i
          :pod
        when /\.(\d)$/i
          :roff
        else
          nil
      end
    end

    # Public: The current version of the page.
    #
    # Returns the Grit::Commit.
    attr_reader :version

    # Public: All of the versions that have touched the Page.
    #
    # Returns an Array of Grit::Commit.
    def versions
      @wiki.repo.log('master', @path)
    end

    #########################################################################
    #
    # Class Methods
    #
    #########################################################################

    # Convert a format Symbol into an extension String.
    #
    # format - The format Symbol.
    #
    # Returns the String extension (no leading period).
    def self.format_to_ext(format)
      case format
        when :markdown then 'md'
        when :textile then 'textile'
        when :rdoc then 'rdoc'
        when :org then 'org'
        when :rest then 'rest'
        when :asciidoc then 'asciidoc'
        when :pod then 'pod'
      end
    end

    #########################################################################
    #
    # Internal Methods
    #
    #########################################################################

    # Set the Grit::Commit version of the page.
    #
    # Returns nothing.
    attr_writer :version

    # Find a page in the given Gollum repo.
    #
    # name    - The human or canonical String page name to find.
    # version - The String version ID to find.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find(name, version)
      commit = @wiki.repo.commit(version)
      if page = find_page_in_tree(commit.tree, name)
        page.version = commit
        page
      else
        nil
      end
    end

    # Find a page in a given tree.
    #
    # tree - The Grit::Tree in which to look.
    # name - The canonical String page name.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find_page_in_tree(tree, name)
      treemap = {}
      trees = [tree]

      while !trees.empty?
        ptree = trees.shift
        ptree.contents.each do |item|
          case item
            when Grit::Blob
              if page_match(name, item.name)
                return populate(item, tree_path(treemap, ptree))
              end
            when Grit::Tree
              treemap[item] = ptree
              trees << item
          end
        end
      end

      return nil # nothing was found
    end

    # Populate the Page with information from the Blob.
    #
    # blob - The Grit::Blob that contains the info.
    # path - The String directory path of the page file.
    #
    # Returns the populated Gollum::Page.
    def populate(blob, path)
      @blob = blob
      @path = (path + '/' + blob.name)[1..-1]
      self
    end

    # The full directory path for the given tree.
    #
    # treemap - The Hash treemap containing parentage information.
    # tree    - The Grit::Tree for which to compute the path.
    #
    # Returns the String path.
    def tree_path(treemap, tree)
      if ptree = treemap[tree]
        tree_path(treemap, ptree) + '/' + tree.name
      else
        ''
      end
    end

    # Compare the canonicalized versions of the two names.
    #
    # name     - The human or canonical String page name.
    # filename - the String filename on disk (including extension).
    #
    # Returns a Boolean.
    def page_match(name, filename)
      if filename =~ VALID_PAGE_RE
        Gollum.canonical_name(name) == Gollum.canonical_name($1)
      else
        false
      end
    end
  end
end