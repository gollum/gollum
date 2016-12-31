module Precious
  module Views
    class Page < Layout
      include HasPage

      attr_reader :content, :page, :header, :footer
      DATE_FORMAT    = "%Y-%m-%d %H:%M:%S"
      DEFAULT_AUTHOR = 'you'

      def title
          @page.title
      end

      def page_header
        title
      end

      def author
        first = page.last_version
        return DEFAULT_AUTHOR unless first
        first.author.name.respond_to?(:force_encoding) ? first.author.name.force_encoding('UTF-8') : first.author.name
      end

      def date
        first = page.last_version
        return Time.now.strftime(DATE_FORMAT) unless first
        first.authored_date.strftime(DATE_FORMAT)
      end

      def noindex
        @version ? true : false
      end

      def editable
        @editable
      end

      def page_exists
        @page_exists
      end

      def allow_editing
        @allow_editing
      end

      def allow_uploads
        @allow_uploads
      end

      def upload_dest
        @upload_dest
      end

      def has_header
        if @header
          @header.formatted_data.strip.empty? ? false : true
        else
          @header = (@page.header || false)
          !!@header
        end
      end

      def header_content
        has_header && @header.formatted_data
      end

      def header_format
        has_header && @header.format.to_s
      end

      def has_footer
        if @footer
          @footer.formatted_data.strip.empty? ? false : true
        else
          @footer = (@page.footer || false)
          !!@footer
        end
      end

      def footer_content
        has_footer && @footer.formatted_data
      end

      def footer_format
        has_footer && @footer.format.to_s
      end

      def bar_side
        @bar_side.to_s
      end

      def has_sidebar
        if @sidebar
          @sidebar.formatted_data.strip.empty? ? false : true
        else
          @sidebar = (@page.sidebar || false)
          !!@sidebar
        end
      end

      def sidebar_content
        has_sidebar && @sidebar.formatted_data
      end

      def sidebar_format
        has_sidebar && @sidebar.format.to_s
      end

      def has_toc
        !@toc_content.nil?
      end

      def toc_content
        @toc_content
      end

      def mathjax
        @mathjax
      end

      def mathjax_config
        @mathjax_config
      end

      def use_identicon
        @page.wiki.user_icons == 'identicon'
      end

      # Access to embedded metadata.
      #
      # Examples
      #
      #   {{#metadata}}{{name}}{{/metadata}}
      #
      # Returns Hash.
      def metadata
        @page.metadata
      end
    end
  end
end
