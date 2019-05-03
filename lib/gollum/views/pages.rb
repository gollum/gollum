require "pathname"

module Precious
  module Views
    class Pages < Layout
      attr_reader :results, :ref, :allow_editing

      def title
        "Overview of #{@ref}"
      end

      def current_path
        @path ? @path : '/'
      end

      def breadcrumb
        if @path
          path       = Pathname.new(@path)
          breadcrumb = [%{<a href="#{pages_path}">Home</a>}]
          path.descend do |crumb|
            title = crumb.basename

            if title == path.basename
              breadcrumb << title
            else
              breadcrumb << %{<a href="#{pages_path}/#{crumb}/">#{title}</a>}
            end
          end

          breadcrumb.join(' / ')
        else
          'Home'
        end
      end


      def delete_file(path)
        %Q(<div class="delete-file" data-file-path="#{path}" data-confirm="Are you sure you want to delete #{path}?"><span><button type="submit" name="delete">Delete</button></span></div>)
      end
      
      def files_folders
        if has_results
          folders = {}
          files = {}

          # 1012: Folders and Pages need to be separated
          @results.each do |result|
            result_path = result.url_path
            result_path = result_path.sub(/^#{Regexp.escape(@path)}\//, '') unless @path.nil?            

            if result_path.include?('/')
              # result contains a folder
              folder      = result_path.split('/').first
              folder_path = @path ? "#{@path}/#{folder}" : folder
              folder_link = %{<li><a href="#{pages_path}/#{folder_path}/" class="folder">#{folder}</a></li>}

              folders[folder] = folder_link unless folders.key?(folder)
            elsif result_path != '.gitkeep'
              # result is either a valid gollum page or another type of file
              klass = (defined? result.format) ? 'page' : 'file'
              url = "#{@base_url}/#{result.escaped_url_path}"
              
              file_link = %{<li><a href="#{url}" class="#{klass}">#{result.filename}</a>#{delete_file(result.url_path) if @allow_editing}</li>}
              files[result.name] = file_link
            end
          end

          # 1012: All Pages should be rendered as Folders first, then Pages, each sorted alphabetically
          result = Hash[folders.sort_by{| key, value | key.downcase} ].values.join("\n") + "\n"
          result += Hash[files.sort_by{ | key, value | key.downcase } ].values.join("\n")

          result
        else
          ''
        end
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
