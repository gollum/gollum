module Gollum
  class PageList
    def initialize(wiki)
      @wiki = wiki
    end

    def render
      pages = @wiki.pages
      pages_li_html = ''
      if pages.size > 0:
        pages_li_html = pages.map { |p| %{<li>#{p.name}</li>} }
      end
      %{<ul id="pages">#{pages_li_html}</ul>}
    end
  end
end
