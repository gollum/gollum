require 'digest/sha1'

module Gollum
  class Markup
    # Initialize a new Markup object.
    #
    # page - The Gollum::Page.
    #
    # Returns a new Gollum::Markup object, ready for rendering.
    def initialize(page)
      @name = page.name
      @data = page.raw_data
      @tagmap = {}
    end

    # Render the content with Gollum wiki syntax on top of the file's own
    # markup language.
    #
    # Returns the formatted String content.
    def render
      data = extract_tags(@data)
      data = GitHub::Markup.render(@name, data) rescue ''
      data = process_tags(data)
    end

    # Extract all tags into the tagmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_tags(data)
      data.gsub(/\[\[(.+?)\]\]/) do
        id = Digest::SHA1.hexdigest($1)
        @tagmap[id] = $1
        id
      end
    end

    # Process all tags from the tagmap and replace the placeholders with the
    # final markup.
    #
    # data - The String data (with placeholders).
    #
    # Returns the marked up String data.
    def process_tags(data)
      @tagmap.each do |id, tag|
        data.sub!(id, process_tag(tag))
      end
      data
    end

    # Process a single tag into its final HTML form.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML version of the tag.
    def process_tag(tag)
      if html = process_image_tag(tag)
        return html
      elsif html = process_file_link_tag(tag)
        return html
      else
        return process_page_link_tag(tag)
      end
    end

    # Attempt to process the tag as an image tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid image tag or nil
    #   if it is not.
    def process_image_tag(tag)
      parts = tag.split('|')
      name = parts[0].strip

      nil
    end

    # Attempt to process the tag as a file link tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid file link tag or nil
    #   if it is not.
    def process_file_link_tag(tag)
      nil
    end

    # Attempt to process the tag as a page link tag.
    #
    # tag - The String tag contents (the stuff inside the double brackets).
    #
    # Returns the String HTML if the tag is a valid page link tag or nil
    #   if it is not.
    def process_page_link_tag(tag)
      parts = tag.split('|')
      name = parts[0].strip
      cname = Gollum::canonical_name((parts[1] || parts[0]).strip)
      %{<a href="#{cname}">#{name}</a>}
    end
  end
end