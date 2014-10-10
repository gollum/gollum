module Precious
	module Views
		class HistoryAll < Layout
			def title
				"Recent activity on Weaki"
			end

			def versions
				i = @versions.size + 1
				versions_temp = @versions.map do |x|
					v = x[0]
          page = x[1]
					i -= 1
					{
						:id => v.id,
						:id7 => v.id[0..6],
						:num => i,
						:author    => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
						:message   => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
						:date      => v.authored_date.strftime("%B %d, %Y %H:%M:%S "),
						:gravatar  => Digest::MD5.hexdigest(v.author.email.strip.downcase),
						:identicon => self._identicon_code(v.author.email),
	          :date_full => v.authored_date,
	          :page_title => page.title,
            :page_url => page.escaped_url_path
					}
				end
				versions_temp.sort_by { |v| v[:date_full] }.reverse
				# versions_temp.sort { |v1, v2|  }
			end

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

      def partial(name)
        if name == :author_template
          self.class.partial("history_authors/none")
        else
          super
        end
      end

		end
	end
end