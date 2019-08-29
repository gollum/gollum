module Precious
  module HasUserIcons
    def user_icon_code(str)
      Digest::MD5.hexdigest(str.strip.downcase)
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