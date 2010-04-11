module Gollum
  class File
    attr_accessor :wiki

    # Initialize a file.
    #
    # wiki - The Gollum::Wiki in question.
    #
    # Returns a newly initialized Gollum::File.
    def initialize(wiki)
      self.wiki = wiki
    end
  end
end