require 'fileutils'
require 'shellwords'
require 'tmpdir'
require 'posix/spawn'

module Gollum
  module Tex
    class Error < StandardError; end

    extend POSIX::Spawn

    Template = <<-EOS
\\documentclass[12pt]{article}
\\usepackage{color}
\\usepackage[dvips]{graphicx}
\\pagestyle{empty}
\\pagecolor{white}
\\begin{document}
{\\color{black}
\\begin{eqnarray*}
%s
\\end{eqnarray*}}
\\end{document}
    EOS

    class << self
      attr_accessor :latex_path, :dvips_path, :convert_path
    end

    self.latex_path   = 'latex'
    self.dvips_path   = 'dvips'
    self.convert_path = 'convert'

    def self.check_dependencies!
      return if @dependencies_available

      if `which latex` == ""
        raise Error, "`latex` command not found"
      end

      if `which dvips` == ""
        raise Error, "`dvips` command not found"
      end

      if `which convert` == ""
        raise Error, "`convert` command not found"
      end

      if `which gs` == ""
        raise Error, "`gs` command not found"
      end

      @dependencies_available = true
    end

    def self.render_formula(formula)
      check_dependencies!

      Dir.mktmpdir('tex') do |path|
        tex_path = ::File.join(path, 'formula.tex')
        dvi_path = ::File.join(path, 'formula.dvi')
        eps_path = ::File.join(path, 'formula.eps')
        png_path = ::File.join(path, 'formula.png')

        ::File.open(tex_path, 'w') { |f| f.write(Template % formula) }

        result = sh latex_path, '-interaction=batchmode', 'formula.tex', :chdir => path
        raise Error, "`latex` command failed: #{result}" unless ::File.exist?(dvi_path)

        result = sh dvips_path, '-o', eps_path, '-E', dvi_path
        raise Error, "`dvips` command failed: #{result}" unless ::File.exist?(eps_path)
        result = sh convert_path, '+adjoin',
          '-antialias',
          '-transparent', 'white',
          '-density', '150x150',
          eps_path, png_path
        raise Error, "`convert` command failed: #{result}" unless ::File.exist?(png_path)

        ::File.read(png_path)
      end
    end

    private
      def self.sh(*args)
        pid = spawn *args
        Process::waitpid(pid)
      end
  end
end
