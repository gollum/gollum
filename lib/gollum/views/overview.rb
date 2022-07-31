require 'pathname'

module Precious
  module Views
    class Overview < Layout
      attr_reader :name, :results, :ref, :allow_editing, :newable
      HIDDEN_PATHS = ['.gitkeep']

      def title
        t[:title]
      end

      # def editable
      #   false
      # end

      def current_path
        @path ? @path : '/'
      end

      def breadcrumb
        if @path
          path       = Pathname.new(@path)
          breadcrumb = [%{<nav aria-label="Breadcrumb"><ol><li class="breadcrumb-item"><a href="#{overview_path}">Home</a></li>}]
          path.descend do |crumb|
            title = crumb.basename

            if title == path.basename
              breadcrumb << %{<li class="breadcrumb-item" aria-current="page">#{CGI.escapeHTML(title.to_s)}</li>}
            else
              breadcrumb << %{<li class="breadcrumb-item"><a href="#{overview_path}/#{crumb}/">#{CGI.escapeHTML(title.to_s)}</a></li>}
            end
          end
          breadcrumb << %{</ol></nav>}
          breadcrumb.join("\n")
        else
          'Home'
        end
      end


      def files_folders
        if has_results
          files_and_folders = []

          @results.each do |result|
            result_path = result.url_path
            result_path = result_path.sub(/^#{Regexp.escape(@path)}\//, '') unless @path.nil?
            if result_path.include?('/')
              # result contains a folder
              folder_name = result_path.split('/').first
              folder_path = @path ? "#{@path}/#{folder_name}" : folder_name
              folder_url  = "#{overview_path}/#{folder_path}/"
              files_and_folders << {name: folder_name, icon: rocticon('file-directory'), type: 'dir', url: folder_url, is_file: false}
            elsif !HIDDEN_PATHS.include?(result_path)
              file_url = page_route(result.escaped_url_path)
              files_and_folders << {name: result.filename, icon: rocticon('file'), type: 'file', url: file_url, file_path: result.escaped_url_path, is_file: true}
            end
          end
          # 1012: Overview should list folders first, followed by files and pages sorted alphabetically
          files_and_folders.uniq{|f| f[:name]}.sort_by!{|f| [f[:type], f[:name]]}
        end
      end


      def has_results
        !@results.empty?
      end

      def no_results
        @results.empty?
      end

      def latest_changes
        true
      end


    end
  end
end
