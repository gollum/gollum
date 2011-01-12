require 'albino'

class Gollum::Albino < Albino
  self.bin              = ::Albino.bin
  self.default_encoding = ::Albino.default_encoding

  def colorize(options = {})
    html = super.to_s
    html.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")
    html
  end
end