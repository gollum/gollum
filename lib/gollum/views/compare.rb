module Precious
  module Views
    class Compare < Layout
      include HasPage

      attr_reader :page, :diff, :versions, :message, :allow_editing

      def title
        "Comparison of #{@page.title}"
      end

      def before
        @versions[0][0..6]
      end

      def after
        @versions[1][0..6]
      end

      def lines
        lines = []
        lines_to_parse = @diff.split("\n")[4..-1]
        # If the diff is of a rename, the diff header will be one line longer than normal because it will contain a line starting with '+++' to indicate the 'new' filename.
        # Make sure to skip that header line if it is present.
        lines_to_parse = lines_to_parse[1..-1] if lines_to_parse[0].start_with?('+++')
        lines_to_parse.each_with_index do |line, line_index|
          lines << { :line  => line,
                     :class => line_class(line),
                     :ldln  => left_diff_line_number(line),
                     :rdln  => right_diff_line_number(line) }
        end if @diff
        lines
      end

      def show_revert
        !@message
      end

      # private

      def line_class(line)
        if line =~ /^@@/
          'gc'
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
        if line =~ /^@@/
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
        if line =~ /^@@/
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
    end
  end
end
