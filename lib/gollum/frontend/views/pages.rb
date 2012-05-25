module Precious
  module Views
    class Pages < Layout
      attr_reader :results, :ref

      def title
        "Browse Files"
      end

      def data_path
        @path =~ /^\/?(.*?)\/?$/
        path  = $1 || ''
        path  << '/' unless path.empty?
        " data-path=\"#{path}\""
      end

      def breadcrumb
        breadcrumb = []
        slugs      = "All Files/#{@path}".split('/')
        slugs.each_index do |index|
          text = slugs[index]
          link = ['/pages']

          if index > 0
            (1..index).each do |position|
              link << slugs[position]
            end
          end

          breadcrumb << "<a href=\"#{link.join('/')}/\">#{text}</a>"
        end

        breadcrumb.join(' / ')
      end

      def files_folders
        files_folders = []
        if has_results
          @results.each do |page|
            page_path = page.path.sub(/^#{@path}\//,'')

            if page_path.include?('/')
              folder      = page_path.split('/').first
              folder_path = folder
              folder_path = "#{@path}/#{folder}" if @path
              folder_link = "<a href=\"/pages/#{folder_path}/\" class=\"folder\">#{folder}</a>"
              files_folders << folder_link if !files_folders.include?(folder_link)
            else
              file_path = page_path
              file_path = "#{@path}/#{page_path}" if @path
              files_folders << "<a href=\"/edit/#{file_path}\" class=\"file\">#{page_path}</a>"
            end
          end
        end

        files_folders.map { |f| "<li>#{f}</li>" }.join("\n")
      end

      def has_results
        !@results.empty?
      end

      def no_results
        @results.empty?
      end
    end
  end
end
