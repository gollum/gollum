require_relative 'compare.rb'

module Precious
  module Views
    class Commit < Compare

      attr_reader :version

      def title
        "Changes in #{@version[0..6]}: #{message}"
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
        files = @diff.force_encoding(Encoding::UTF_8).scan(%r{
          ^diff\ --git\         # diff start
          .+?                   # diff body
          (?=^diff\ --git|\Z)   # scan until next diff or string
        }sxmu)

        files.map do |diff|
          match = diff.match(%r{^diff --git (")?[ab]/(.+)(?(1)") (")?[ab]/(.+)(?(3)")})
          path = match[2]
          path = match[4] if path.nil?

          {
            path: path,
            lines: lines(diff)
          }
        end
      end
    end
  end
end
