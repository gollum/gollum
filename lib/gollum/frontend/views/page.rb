module Precious
  module Views
    class Page < Layout
      attr_reader :content, :page

      def human_name
        @name.gsub(/-/, ' ')
      end

      def title
        "A Page"
      end

      def author
        @page.version.author.name
      end

      def date
        @page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S")
      end

      def versions
        i = @page.versions.size + 1
        @page.versions.map do |v|
          i -= 1
          { :id => v.id,
            :id7 => v.id[0..6],
            :num => i,
            :author => v.author.name }
        end
      end
    end
  end
end
