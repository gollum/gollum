require_relative 'compare.rb'

module Precious
  module Views
    class Commit < Compare

      attr_reader :version

      def title
        "Changes in #{@version[1..7]}: #{message}"
      end

      def author
        @commit.author.name
      end

      def authored_date
        @commit.authored_date
      end

      def message
        @commit.message
      end

      def files
        files = @diff.split(%r{^diff --git a/.+ b/.+$}).reject(&:empty?)
        files.map do |diff|
          matched = diff.match(%r{(?<=^--- a/).+$})
          matched = diff.match(%r{(?<=^\+\+\+ b/).+$}) if matched.nil?
          {
            path: matched[0],
            lines: lines(diff)
          }
        end
      end
    end
  end
end
