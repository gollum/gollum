module Precious
  module Views
    class History < Layout
      include HasPage

      attr_reader :page, :page_num, :allow_editing

      def title
        @page.title
      end

      def versions
        i = @versions.size + 1
        @versions.map do |v|
          i -= 1
          { :id        => v.id,
            :id7       => v.id[0..6],
            :num       => i,
            :selected  => @page.version.id == v.id,
            :author    => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message   => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
            :date      => v.authored_date.strftime("%B %d, %Y"),
            :gravatar  => Digest::MD5.hexdigest(v.author.email.strip.downcase),
            :identicon => self._identicon_code(v.author.email),
            :date_full => v.authored_date,
          }
        end
      end

      # http://stackoverflow.com/questions/9445760/bit-shifting-in-ruby
      def left_shift int, shift
        r = ((int & 0xFF) << (shift & 0x1F)) & 0xFFFFFFFF
        # 1>>31, 2**32
        (r & 2147483648) == 0 ? r : r - 4294967296
      end

      def string_to_code string
        # sha bytes
        b = [Digest::SHA1.hexdigest(string)[0, 20]].pack('H*').bytes.to_a
        # Thanks donpark's IdenticonUtil.java for this.
        # Match the following Java code
        # ((b[0] & 0xFF) << 24) | ((b[1] & 0xFF) << 16) |
        #	 ((b[2] & 0xFF) << 8) | (b[3] & 0xFF)

        return left_shift(b[0], 24) |
            left_shift(b[1], 16) |
            left_shift(b[2], 8) |
            b[3] & 0xFF
      end

      def _identicon_code(blob)
        string_to_code blob + @request.host
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
