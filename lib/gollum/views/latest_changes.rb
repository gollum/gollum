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
            :href      => page_route("gollum/commit/#{v.id}"),
            :num       => i,
            :author    => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message   => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
            :date      => v.authored_date.strftime("%B %d, %Y"),
            :user_icon => self.user_icon_code(v.author.email),
            :date_full => v.authored_date,
            :files     => v.stats.files.map { |f|
              new_path = extract_page_dir(f[:new_file])
              { :file => new_path,
                :link => "#{page_route(new_path)}/#{v.id}",
                :renamed => f[:old_file] ? extract_page_dir(f[:old_file]) : nil
              }
            }
          }
        end
      end

    end
  end
end
