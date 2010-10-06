# This is going to serve as an example class, showing of how to use
# the extension API in the simplest way possible.
#   We start of by creating the class. It doesn't actually have to be
# a class in Gollum.
module Gollum
  # Neither is it neccessary to extend ExtensionTag, but this class 
  # has the initialize method already.
  #   If we wanted to, we could create our own initialize, as long as
  # we have the two arguments
  class PageList < Gollum::ExtensionTag
    # The 'render' method is needed
    def render
      # You work your magic...
      pages = @wiki.pages
      pages_li_html = ''
      if pages.size > 0:
        pages_li_html = pages.map { |p| %{<li>#{p.name}</li>} }
      end
      # Just remember to return a string
      %{<ul id="pages">#{pages_li_html}</ul>}
      # The returned string is what is going to be replace the tag.
    end
  end
end

# Finally, when the class has been made, we have to register it.
#   A class is registrated by calling the following function like so
Gollum::ExtensionTag.register_extension_tag('pages', Gollum::PageList)
# The first argument is the ´tag´ Gollum will be looking for, the 
# second is the class that is going to do the magic.
