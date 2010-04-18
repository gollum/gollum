module Gollum
  class Markup
    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # name - The String filename of the page.
    # data - The String contents of the page.
    #
    # Returns the formatted String content.
    def self.render(name, data)
      GitHub::Markup.render(name, data) rescue nil
    end
  end
end