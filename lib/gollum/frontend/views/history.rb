module Precious
  module Views
    class History < Layout
      include HasPage

      attr_reader :page, :page_num

      def title
        @page.title
      end

      def versions
        i = @versions.size + 1
        @versions.map do |v|
          i -= 1
          { :id       => v.id,
            :id7      => v.id[0..6],
            :num      => i,
            :selected => @page.version.id == v.id,
            :author   => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message  => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
            :date     => v.committed_date.strftime("%B %d, %Y"),
            :gravatar => Digest::MD5.hexdigest(v.author.email) }
        end
      end

      def previous_link
        label = "&laquo; Previous"
        if @page_num == 1
          %(<span class="disabled">#{label}</span>)
        else
          link = url("/history/#{@page.name}?page=#{@page_num-1}")
          %(<a href="#{link}" hotkey="h">#{label}</a>)
        end
      end

      def next_link
        label = "Next &raquo;"
        if @versions.size == Gollum::Page.per_page
          link = "/history/#{@page.name}?page=#{@page_num+1}"
          %(<a href="#{link}" hotkey="l">#{label}</a>)
        else
          %(<span class="disabled">#{label}</span>)
        end
      end
    end
  end
end
