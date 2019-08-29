module Precious
  module Views
    class History < Layout
      include HasPage
      include Pagination
      include HasUserIcons
      include Sprockets::Helpers
      include Precious::Views::SprocketsHelpers

      attr_reader :page, :allow_editing

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
            :gravatar  => self._gravatar_code(v.author.email.strip.downcase),
            :identicon => self._identicon_code(v.author.email),
            :date_full => v.authored_date,
          }
        end
      end
      
      def editable
        @editable
      end
    end
  end
end
