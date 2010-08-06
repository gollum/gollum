module Precious
  module Views
    class History < Layout
      attr_reader :page

      def title
        "History of #{@page.title}"
      end

      def versions
        i = @page.versions.size + 1
        @page.versions.map do |v|
          i -= 1
          { :id => v.id,
            :id7 => v.id[0..6],
            :num => i,
            :selected => @page.version.id == v.id,
            :author => v.author.name,
            :message => v.message,
            :date => v.committed_date.strftime("%B %d, %Y"),
            :gravatar => Digest::MD5.hexdigest(v.author.email) }
        end
      end
    end
  end
end
