module Gollum
  class Page
    VALID_PAGE_RE = /^(.+)\.(md|mkdn?|mdown|markdown|textile|rdoc|org|re?st(\.txt)?|asciidoc|pod|\d)$/i

    attr_accessor :wiki, :blob, :path, :version

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
    # path - The String directory path of the page file.
    #
    # Returns the populated Gollum::Page.
    def populate(blob, path)
      self.blob = blob
      self.path = (path + '/' + blob.name)[1..-1]
      self
    end

    # The on-disk filename of the page.
    #
    # Returns the String name.
    def name
      self.blob.name rescue nil
    end

    # The formatted contents of the page.
    #
    # Returns the String data.
    def formatted_data
      GitHub::Markup.render(self.blob.name, self.blob.data) rescue nil
    end

    # The raw contents of the page.
    #
    # Returns the String data.
    def raw_data
      self.blob.data rescue nil
    end

    # The format of the page.
    #
    # Returns the Symbol format of the page. One of:
    #   [ :markdown | :textile | :rdoc | :org | :rest | :asciidoc | :pod |
    #     :roff ]
    def format
      case blob.name
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

    # All of the versions that have touched this Page.
    #
    # Returns an Array of Gollum::Version.
    def versions
      @wiki.repo.log('master', self.path).map do |v|
        Version.new(v)
      end
    end

    # Find a page in the given Gollum repo.
    #
    # name - The human or canonical String page name to find.
    #
    # Returns a Gollum::Page or nil if the page could not be found.
    def find(name)
      commit = self.wiki.repo.commits.first
      if page = find_page_in_tree(commit.tree, name)
        page.version = Version.new(commit)
        page
      else
        nil
      end
    end

    # private

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