module Precious
  module Views
    class LatestChanges < Layout
      include Pagination
      include HasUserIcons

      attr_reader :wiki

      def title
        "Latest Changes (Globally)"
      end

      def versions
        i = @versions.size + 1
        @versions.map do |v|
          i -= 1
          { :id        => v.id,
            :id7       => v.id[0..6],
            :num       => i,
            :author    => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message   => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
            :date      => v.authored_date.strftime("%B %d, %Y"),
            :gravatar  => self._gravatar_code(v.author.email.strip.downcase),
            :identicon => self._identicon_code(v.author.email),
            :date_full => v.authored_date,
            :files     => v.stats.files.map { |f,*rest|
              page_path = extract_renamed_path_destination(f)
              { :file => f,
                :link => "#{page_path}/#{v.id}"
              }
            }
          }
        end
      end

      def extract_renamed_path_destination(file)
        return file.gsub(/{.* => (.*)}/, '\1').gsub(/.* => (.*)/, '\1')
      end

      def previous_link
      end

      def next_link
      end
    end
  end
end
