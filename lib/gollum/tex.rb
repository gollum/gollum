require 'escape_utils'

module Gollum
  module Tex
    TEX_URL = "http://www.mathtran.org/cgi-bin/toy/"
    TEX_SIZES = { :inline => 2, :block => 4 }

    def self.to_html(tex, type = :inline)
      tex_uri = EscapeUtils.escape_uri(tex)
      tex_alt = EscapeUtils.escape_html(tex)
      %{<img src="#{TEX_URL}?D=#{TEX_SIZES[type]};tex=#{tex}" alt="#{tex_alt}">}
    end
  end
end
