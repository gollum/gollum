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
            :date     => v.authored_date.strftime("%B %d, %Y"),
            :gravatar => Digest::MD5.hexdigest(v.author.email),
            :identicon => self._identicon_code(v.author.email),
          }
        end
      end

      def _identicon_code(blob)
        sha_bytes = Digest::SHA1.hexdigest(blob + @request.host)[0,20]
        # Thanks donpark's IdenticonUtil.java for this.
        return  ((sha_bytes[0] & 0xFF) << 24) |
                ((sha_bytes[1] & 0xFF) << 16) |
                ((sha_bytes[2] & 0xFF) << 8) |
                (sha_bytes[3] & 0xFF)
      end

      def use_identicon
          @page.wiki.user_icons == 'identicon'
      end

      def partial(name)
        if name == :author_template
          self.class.partial("history_authors/#{@page.wiki.user_icons}")
        else
          super
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
