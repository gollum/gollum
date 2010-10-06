module Gollum
  class ExtensionTag
    # Register a tag so it can be used in the markup.
    #
    # tag - String, the string that is in the first part of the tag
    #
    # extension - Class, the class that handles the tag contents.
    #             This class must at least have a method called render,
    #             that returns a string.
    #             The class constructor must take two arguments:
    #               wiki and tag
    #
    #             wiki - The wiki class of Gollum (use it to find pages)
    #             tag  - The entire content of the tag (everything in
    #                    between {{}})
    def self.register_dynamic_tag(tag, extension)
      extensions[tag] = extension
    end

    # Returns all of the currently registrated extensions
    def self.extensions
      @extension ||= {}
    end

    # Standard way of initializing a class
    def initialize(wiki, tag)
      @wiki = wiki
      @tag = tag
    end
  end
end
