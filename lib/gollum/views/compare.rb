module Precious
  module Views
    class Compare < Layout
      include HasPage

      attr_reader :page, :diff, :versions, :message, :allow_editing

      def title
        [t[:comparison_of], @page.title].join(" ")
      end

      def before
        @versions[0][0..6]
      end

      def after
        @versions[1][0..6]
      end

      def lines(diff = @diff)
        lines = []
        lines_to_parse = diff.split("\n")[3..-1]
        lines_to_parse = lines_to_parse[2..-1] if lines_to_parse[0] =~ /^(---|rename to )/

        if lines_to_parse.nil? || lines_to_parse.empty?
          lines_to_parse = []  # File is created without content
        else
          lines_to_parse = lines_to_parse[1..-1] if lines_to_parse[0].start_with?('+++')
        end

        lines_to_parse.each_with_index do |line, line_index|
          lines << { :line  => line,
                     :class => line_class(line),
                     :ldln  => left_diff_line_number(line),
                     :rdln  => right_diff_line_number(line) }
        end
        lines
      end

      def show_revert
        !@message
      end

      # private

      def line_class(line)
        if line =~ /^@@/
          'gc'
        elsif git_line?(line)
          'gg'
        elsif line =~ /^\+/
          'gi'
        elsif line =~ /^\-/
          'gd'
        else
          ''
        end
      end

      @left_diff_line_number = nil

      def left_diff_line_number(line)
        if git_line?(line)
          m, li                  = *line.match(/\-(\d+)/)
          @left_diff_line_number = li.to_i
          @current_line_number   = @left_diff_line_number
          ret                    = '...'
        elsif line[0] == ?-
          ret                    = @left_diff_line_number.to_s
          @left_diff_line_number += 1
          @current_line_number   = @left_diff_line_number - 1
        elsif line[0] == ?+
          ret = ' '
        else
          ret                    = @left_diff_line_number.to_s
          @left_diff_line_number += 1
          @current_line_number   = @left_diff_line_number - 1
        end
        ret
      end

      @right_diff_line_number = nil

      def right_diff_line_number(line)
        if git_line?(line)
          m, ri                   = *line.match(/\+(\d+)/)
          @right_diff_line_number = ri.to_i
          @current_line_number    = @right_diff_line_number
          ret                     = '...'
        elsif line[0] == ?-
          ret = ' '
        elsif line[0] == ?+
          ret                     = @right_diff_line_number.to_s
          @right_diff_line_number += 1
          @current_line_number    = @right_diff_line_number - 1
        else
          ret                     = @right_diff_line_number.to_s
          @right_diff_line_number += 1
          @current_line_number    = @right_diff_line_number - 1
        end
        ret
      end

      def git_line?(line)
        !!(line =~ /^(\\ No newline|Binary files|@@)/)
      end
    end
  end
end
