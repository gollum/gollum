module Gollum
  class Markup
    register(:markdown,  "Markdown", :regexp => /md|mkdn?|mdown|markdown/)
    register(:textile,   "Textile")
    register(:rdoc,      "RDoc")
    register(:org,       "Org-mode")
    register(:creole,    "Creole")
    register(:rest,      "reStructuredText", :regexp => /re?st(\.txt)?/)
    register(:asciidoc,  "AsciiDoc")
    register(:mediawiki, "MediaWiki", :regexp => /(media)?wiki/)
    register(:pod,       "Pod")
  end
end