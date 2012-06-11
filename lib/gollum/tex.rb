require 'fileutils'
require 'shellwords'
require 'tmpdir'
require 'posix/spawn'
require 'base64'

module Gollum
  module Tex
    class Error < StandardError; end

    extend POSIX::Spawn

    Template = <<-EOS
\\documentclass[11pt]{article}
\\pagestyle{empty}
\\setlength{\\topskip}{0pt}
\\setlength{\\parindent}{0pt}
\\setlength{\\abovedisplayskip}{0pt}
\\setlength{\\belowdisplayskip}{0pt}

\\usepackage{geometry}

\\usepackage{amsfonts}
\\usepackage{amsmath}

\\newsavebox{\\snippetbox}
\\newlength{\\snippetwidth}
\\newlength{\\snippetheight}
\\newlength{\\snippetdepth}
\\newlength{\\pagewidth}
\\newlength{\\pageheight}
\\newlength{\\pagemargin}

\\begin{lrbox}{\\snippetbox}%
\$%s\$
\\end{lrbox}

\\settowidth{\\snippetwidth}{\\usebox{\\snippetbox}}
\\settoheight{\\snippetheight}{\\usebox{\\snippetbox}}
\\settodepth{\\snippetdepth}{\\usebox{\\snippetbox}}

\\setlength\\pagemargin{4pt}

\\setlength\\pagewidth\\snippetwidth
\\addtolength\\pagewidth\\pagemargin
\\addtolength\\pagewidth\\pagemargin

\\setlength\\pageheight\\snippetheight
\\addtolength{\\pageheight}{\\snippetdepth}
\\addtolength\\pageheight\\pagemargin
\\addtolength\\pageheight\\pagemargin

\\newwrite\\foo
\\immediate\\openout\\foo=\\jobname.dimensions
  \\immediate\\write\\foo{snippetdepth = \\the\\snippetdepth}
  \\immediate\\write\\foo{snippetheight = \\the\\snippetheight}
  \\immediate\\write\\foo{snippetwidth = \\the\\snippetwidth}
  \\immediate\\write\\foo{pagewidth = \\the\\pagewidth}
  \\immediate\\write\\foo{pageheight = \\the\\pageheight}
  \\immediate\\write\\foo{pagemargin = \\the\\pagemargin}
\\closeout\\foo

\\geometry{paperwidth=\\pagewidth,paperheight=\\pageheight,margin=\\pagemargin}

\\begin{document}%
\\usebox{\\snippetbox}%
\\end{document}
    EOS

    class << self
      attr_accessor :latex_path
    end

    self.latex_path   = 'pdflatex'

    def self.check_dependencies!
      return if @dependencies_available

      if `which pdflatex` == ""
        raise Error, "`pdflatex` command not found"
      end

      if `which gs` == ""
        raise Error, "`gs` command not found"
      end
      
      if `which pnmcrop` == ""
        raise Error, "`pnmcrop` command not found"
      end

      if `which pnmpad` == ""
        raise Error, "`pnmpad` command not found"
      end

      if `which pnmscale` == ""
        raise Error, "`pnmscale` command not found"
      end
      
      if `which ppmtopgm` == ""
        raise Error, "`ppmtopgm` command not found"
      end
      
      if `which pnmgamma` == ""
        raise Error, "`pnmgamma` command not found"
      end
      
      if `which pnmtopng` == ""
        raise Error, "`pnmtopng` command not found"
      end

      @dependencies_available = true
    end

    # Render the formula and calculate the correct alignment
    # for the image in the html. 
    #
    # This is a ruby implementation of the Perl version described 
    # at http://tex.stackexchange.com/questions/44486/pixel-perfect-vertical-alignment-of-image-rendered-tex-snippets
    #
    # The main caveat is that rendering takes quite a bit of processing power,
    # which can make the page load slowly if it has to render each time. 
    # For this reason, the method caches the rendered formula in `/tmp` for reduced
    # loading time in subsequent loads.
    #   
    # @param formula the tex formula to render
    # @param with_properties, if true it returns an array with a base64
    #   string with the image, and the alignment values for the image. 
    #   Otherwise it returns the binary image.
    def self.render_formula(formula, with_properties=false)
      check_dependencies!

      render_antialias_bits = 4
        render_oversample = 4
        display_oversample = 4
        gamma = 0.3
        if !with_properties
            display_oversample = 1
            gamma = 0.5
        end

        oversample = render_oversample * display_oversample
        render_dpi = 96*1.2 * 72.27/72 * oversample # This is 1850.112 dpi.


        # Cache rendered formula and returned cached version if it exists

        # First look for the .cache directory in the home folder
        cache_dir = ::File.expand_path("~/.cache") 
        if not ::File.exists?(cache_dir) or not ::File.directory?(cache_dir)
            ::Dir.mkdir(cache_dir)
        end

        # Check that the gollum directory exists inside the cache dir
        cache_dir = ::File.join(cache_dir, "gollum")
        if not ::File.exists?(cache_dir) or not ::File.directory?(cache_dir)
            ::Dir.mkdir(cache_dir)
        end

        # Check for the formula in the cache dir
        hash = Digest::SHA1.hexdigest(formula)
        cache_file = ::File.join(cache_dir, "tex-#{hash}")

        if ::File.exists?(cache_file)
            width, height, align, base64 = ::File.open(cache_file, 'rb') { |io| io.read }.split(",")

            if with_properties
                return width, height, align, base64
            else
                return Base64.decode64(base64)
            end
        end
        
        Dir.mktmpdir('tex') do |path|
            file = ::File.join(path, "formula")

            # --- Write TeX source and compile to PDF.Write snippet into template
            ::File.open(file + ".tex", 'w') { |f| f.write(Template % formula) }

            result = sh_chdir path, "pdflatex",
                "-halt-on-error",
                "-output-directory=#{path}",
                "-output-format=pdf",
                "#{file}.tex",
                ">#{file}.err 2>&1"



            # --- Convert PDF to PNM using Ghostscript.
            sh "gs",
                "-q -dNOPAUSE -dBATCH",
                "-dTextAlphaBits=#{render_antialias_bits}",
                "-dGraphicsAlphaBits=#{render_antialias_bits}",
                "-r#{render_dpi}",
                "-sDEVICE=pnmraw",
                "-sOutputFile=#{file}.pnm",
                "#{file}.pdf"


            img_width, img_height = pnm_width_height(file + ".pnm")


            # --- Read dimensions file written by TeX during processing.
            #
            #     Example of file contents:
            #       snippetdepth = 6.50009pt
            #       snippetheight = 13.53899pt
            #       snippetwidth = 145.4777pt
            #       pagewidth = 153.4777pt
            #       pageheight = 28.03908pt
            #       pagemargin = 4.0pt
            dimensions = {}
            ::File.open(file + ".dimensions").readlines.each_with_index do |line, i|
                if line =~ /^(\S+)\s+=\s+(-?[0-9\.]+)pt$/
                    dimensions[$1] = Float($2) / 72.27 * render_dpi
                else 
                    raise Error, "#{file}.dimensions: invalid line: #{i}" 
                end
            end

            # --- Crop bottom, then measure how much was cropped.
            sh "pnmcrop -white -bottom #{file}.pnm >#{file}.bottomcrop.pnm"
            #raise Error, "`pnmcrop` command failed: #{result}" unless ::File.exist?(file + ".bottomcrop.pnm")

            img_width_bottomcrop, img_height_bottomcrop = pnm_width_height("#{file}.bottomcrop.pnm")
            bottomcrop = img_height - img_height_bottomcrop
            
            # --- Crop top and sides, then measure how much was cropped from the top.
            sh "pnmcrop -white #{file}.bottomcrop.pnm > #{file}.crop.pnm"
            #raise Error, "`pnmcrop` command failed: #{result}" unless ::File.exist?(file + ".crop.pnm")

            cropped_img_width, cropped_img_height = pnm_width_height("#{file}.crop.pnm")
            topcrop = img_height_bottomcrop - cropped_img_height

            # --- Pad image with specific values on all four sides, in preparation for
            #     downsampling.

            # Calculate bottom padding.
            snippet_depth = Integer(dimensions["snippetdepth"] + dimensions["pagemargin"] + 0.5) - bottomcrop
            padded_snippet_depth = round_up(snippet_depth, oversample)
            increase_snippet_depth = padded_snippet_depth - snippet_depth
            bottom_padding = increase_snippet_depth
            
            # --- Next calculate top padding, which depends on bottom padding.

            padded_img_height = round_up(cropped_img_height + bottom_padding,
                oversample)
            top_padding = padded_img_height - (cropped_img_height + bottom_padding)


            # --- Calculate left and right side padding.  Distribute padding evenly.

            padded_img_width = round_up(cropped_img_width, oversample)
            left_padding = Integer((padded_img_width - cropped_img_width) / 2.0)
            right_padding = (padded_img_width - cropped_img_width) - left_padding


            # --- Pad the final image.
            result = sh "pnmpad",
                "-white",
                "-bottom=#{bottom_padding}",
                "-top=#{top_padding}",
                "-left=#{left_padding}",
                "-right=#{right_padding}",
                "#{file}.crop.pnm",
                ">#{file}.pad.pnm"

            # --- Sanity check of final size.
            final_pnm_width, final_pnm_height = pnm_width_height(file + ".pad.pnm")
            raise Error, "#{final_pnm_width} is not a multiple of #{oversample}" unless final_pnm_width % oversample == 0
            
            raise "#{final_pnm_height} is not a multiple of #{oversample}" unless final_pnm_height % oversample == 0

            # --- Convert PNM to PNG.

            final_png_width  = final_pnm_width  / render_oversample
            final_png_height = final_pnm_height / render_oversample

            result = sh "cat #{file}.pad.pnm",
                "| ppmtopgm",
                "| pnmscale -reduce #{render_oversample}",
                "| pnmgamma #{gamma}",
                "| pnmtopng -compression 9",
                "> #{file}.png"

            raise Error, "Conversion to png failed: #{result}" unless ::File.exist?(file + ".png")

            # Calculate html properties
            html_img_width  = final_png_width  / display_oversample
            html_img_height = final_png_height / display_oversample
            html_img_vertical_align = sprintf("%.0f", -padded_snippet_depth / oversample) 
            png_data_base64 = Base64.encode64(::File.open("#{file}.png") { |io| io.read }).chomp

            ::File.open(cache_file, 'w') { |f| f.write(%{#{html_img_width},#{html_img_height},#{html_img_vertical_align},#{png_data_base64}}) }
            if with_properties
                return html_img_width, html_img_height, html_img_vertical_align, png_data_base64
            else
                ::File.read(file + ".png")
            end
        end
    end

    private
      def self.sh_chdir(path, *args)  
        origcommand = args * " "
        return if origcommand == ""

        command = origcommand
        command.gsub! /(["\\])/, "\\$1"
        command = %{/bin/sh -c "(#{command}) 2>&1"}

        pid = spawn command, :chdir => path

        result = Process::waitpid(pid)
        exit_value = Integer($? >> 8), signal_num = Integer($? & 127), dumped_core = Integer($? & 128)
        raise Error, "Failed #{result}: #{origcommand}. Exit value = #{exit_value}. Signal Num = #{signal_num}. Dumped core = #{dumped_core}" unless $?.success?

        return result
      end

      def self.sh(*args)
        origcommand = args * " "
        return if origcommand == ""

        command = origcommand
        command.gsub! /(["\\])/, "\\$1"
        command = %{/bin/sh -c "(#{command}) 2>&1"}

        pid = spawn command
        #pid = spawn *args
        result = Process::waitpid(pid)
        exit_value = $? >> 8, signal_num = $? & 127, dumped_core = $? & 128
        raise Error, "Failed #{result}: #{origcommand}. Exit value = #{exit_value}. Signal Num = #{signal_num}. Dumped core = #{dumped_core}" unless $?.success?

        return result
      end

      def self.round_up(num, mod)
        num + (num % mod == 0 ? 0 : (mod - (num % mod)))
      end

      def self.pnm_width_height(filename) 
        raise Error, "#{filename} is not a .pnm file" if filename !~ /\.pnm$/ 

        width = nil, height = nil
        ::File.open(filename) do |file|
          # Read first line
          line = file.gets
          begin 
            line = file.gets # Read next line, skipping comments
          end while line && line =~ /^#/

          if line =~ /^(\d+)\s+(\d+)$/
            width  = Integer($1)
            height = Integer($2)
          else 
            raise Error, "#{filename}: couldn't read image size"
          end
        end

        raise Error, "#{filename}: couldn't read image size" unless width && height

        return width, height
      end      

  end
end
