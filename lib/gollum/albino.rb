require 'albino/multi'

class Gollum::Albino < Albino::Multi
  self.bin = ::Albino::Multi.bin

  def colorize(options = {})
    case out = super
      when Array then out.each { |s| fix_html(s) }
      else fix_html(out)
    end
  end

  def fix_html(html)
    html.sub!(%r{</pre></div>\Z}, "</pre>\n</div>")
    html
  end
end
