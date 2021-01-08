module Precious
  module Views
    class History < Layout
      DATE_FORMAT = '%B %d, %Y'

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
          filename = path_for_version(v.tracked_pathname)
          authored_date = v.authored_date
          { :id          => v.id,
            :id7         => v.id[0..6],
            :href        => page_route("gollum/commit/#{v.id}"),
            :href_page   => page_route("#{filename}/#{v.id}"),
            :num         => i,
            :selected    => @page.version.id == v.id,
            :author      => v.author.name.respond_to?(:force_encoding) ? v.author.name.force_encoding('UTF-8') : v.author.name,
            :message     => v.message.respond_to?(:force_encoding) ? v.message.force_encoding('UTF-8') : v.message,
            :date_full   => authored_date,
            :date        => authored_date.strftime(DATE_FORMAT),
            :datetime    => authored_date.utc.iso8601,
            :date_format => DATE_FORMAT,
            :user_icon   => self.user_icon_code(v.author.email),
            :filename    => filename
          }
        end
      end
      
      def editable
        @editable
      end

      private

      def path_for_version(pathname)
        @preview_page ||= Gollum::PreviewPage.new(@wiki, '', '', nil)
        @preview_page.path = pathname ? pathname : @name
        @preview_page.escaped_url_path
      end

    end
  end
end
