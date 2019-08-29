module Precious
  module HasUserIcons
    # http://stackoverflow.com/questions/9445760/bit-shifting-in-ruby
    def left_shift(int, shift)
      r = ((int & 0xFF) << (shift & 0x1F)) & 0xFFFFFFFF
      # 1>>31, 2**32
      (r & 2147483648) == 0 ? r : r - 4294967296
    end

    def string_to_code(string)
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

    def _identicon_code(str)
      string_to_code(str + @request.host)
    end

    def _gravatar_code(str)
      Digest::MD5.hexdigest(str)
    end

    def partial(name)
      if name == :author_template
        self.class.partial("history_authors/#{@wiki.user_icons}")
      else
        super
      end
    end
  end
end