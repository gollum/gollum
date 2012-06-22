require "pathname"

module Precious
  module Views
    class Pages < Layout
      attr_reader :results, :ref

      def title
        "All pages in #{@ref}"
      end

      def new_page_data_variables
        %{ data-path="#{@path}"} if @path
      end

      def breadcrumb
        if @path
          path = Pathname.new(@path)
          breadcrumb = [%{<a href="/pages/">Home</a>}]
          path.descend do |crumb|
            title = crumb.basename

            if title == path.basename
              breadcrumb << title
            else
              breadcrumb << %{<a href="/pages/#{crumb}/">#{title}</a>}
            end
          end

          breadcrumb.join(" / ")
        else
          "Home"
        end
      end

      def files_folders
        if has_results
          folder_links = []

          @results.map { |page|
            page_path = page.path.sub(/^#{@path}\//,'')

            if page_path.include?('/')
              folder      = page_path.split('/').first
              folder_path = @path ? "#{@path}/#{folder}" : folder
              folder_link = %{<li><a href="/pages/#{folder_path}/" class="folder">#{folder}</a></li>}

              unless folder_links.include?(folder_link)
                folder_links << folder_link

                folder_link
              end
            elsif page_path != ".gitkeep"
              %{<li><a href="/#{page.escaped_url_path}" class="file">#{page.name}</a></li>}
            end
          }.compact.join("\n")
        else
          ""
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
