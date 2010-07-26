module Precious
  module Views
    class Page < Layout
      attr_reader :content, :page, :footer

      def human_name
        @page.title
      end

      def title
        "A Page"
      end

      def format
        @page.format.to_s
      end

      def author
        @page.version.author.name
      end

      def date
        @page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S")
      end

      def has_footer
        @footer ||= @page.footer
        !@footer.nil?
      end

      def footer_content
        @footer ||= @page.footer
        @footer.formatted_data
      end

      def footer_format
        @footer ||= @page.footer
        @footer.format.to_s
      end

      def versions
        i = @page.versions.size + 1
        @page.versions.map do |v|
          i -= 1
          { :id => v.id,
            :id7 => v.id[0..6],
            :num => i,
            :selected => @page.version.id == v.id,
            :author => v.author.name }
        end
      end
    end
  end
end
