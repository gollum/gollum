require 'escape_utils'

module Gollum
  module Tex
    TEX_URL = "http://www.mathtran.org/cgi-bin/toy/"
    TEX_SIZES = { :inline => 2, :block => 4 }
    TEX_ENV = { :inline => lambda { |tex| "\\(#{tex}\\)" }, :block => lambda { |tex| "\\[#{tex}\\]" } }

    def self.to_html(tex, type = :inline)
      tex_uri = EscapeUtils.escape_uri(tex).gsub(/\+/, '%2B')
      tex_alt = EscapeUtils.escape_html(tex)
      %{<img src="#{TEX_URL}?D=#{TEX_SIZES[type]};tex=#{tex_uri}" alt="#{tex_alt}">}
    end

    def self.to_tex(tex, type = :inline)
      TEX_ENV[type].call(tex)
    end

  end
end
