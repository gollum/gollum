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

  # Hotfix for vulnerable versions of Albino
  if !instance_methods.include?('shell_escape')
    def convert_options(options = {})
      @options.merge(options).inject('') do |string, (flag, value)|
        string + " -#{flag} #{shell_escape value}"
      end
    end

    def shell_escape(str)
      str.to_s.gsub("'", "\\\\'").gsub(";", '\\;')
    end
  end
end