require 'albino'

class Gollum::Albino < Albino
  def self.bin
    Albino.bin
  end

  def bin
    Albino.bin
  end

  def colorize(options = {})
    html = super.to_s
    html.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")
    html
  end
end