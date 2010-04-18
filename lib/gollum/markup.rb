module Gollum
  class Markup
    # Initialize a new Markup object.
    #
    # name - The String filename of the page.
    # data - The String contents of the page.
    #
    # Returns a new Gollum::Markup object, ready for rendering.
    def initialize(name, data)
      @name = name
      @data = data
      @tagmap = {}
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # Returns the formatted String content.
    def render
      base_markup = GitHub::Markup.render(@name, @data) rescue nil
    end

    # Extract all tags into the tagmap and replace with placeholders.
    #
    # Returns nothing.
    def extract_tags

    end
  end
end