module Gollum
=begin
  FileView requires that:
    - All files in root dir are processed first
    - Then all the folders are sorted and processed
=end
  class FileView
    def initialize pages
      @pages = pages
    end

    def enclose_tree string
      %Q(<ol class="tree">\n) + string + %Q(</ol>)
    end

    def new_page page
      name = page.name
      url  = page.filename_stripped
      %Q(  <li class="file"><a href="#{url}">#{name}</a></li>\n)
    end

    def new_folder folder_path
      new_sub_folder folder_path
    end

    def new_sub_folder path
      <<-HTML
      <li>
        <label>#{path}</label> <input type="checkbox" checked />
        <ol>
      HTML
    end

    def end_folder
      <<-HTML
        </ol>
      </li>
      HTML
    end

    def render_files
      html = ''
      count = @pages.size
      folder_start = -1

      # Process all pages until folders start
      count.times do | index |
        page = @pages[ index ]
        path = page.path

        unless path.include? '/'
          # Page processed (not contained in a folder)
          html += new_page page
        else
          # Folders start at the next index
          folder_start = index
          break # Pages finished, move on to folders
        end
      end

      # If there are no folders, then we're done.
      return enclose_tree(html) if folder_start <= -1

      # Handle special case of only one folder.
      if (count - folder_start == 1)
        page = @pages[ folder_start ]
        name = page.name
        url  = page.filename_stripped
        html += <<-HTML
        <li>
          <label>#{::File.dirname(page.path)}</label> <input type="checkbox" checked />
          <ol>
            <li class="file"><a href="#{url}">#{name}</a></li>
         </ol>
        </li>
        HTML

        return enclose_tree html
      end

      sorted_folders = []
      (folder_start).upto count - 1 do | index |
        sorted_folders += [[ @pages[ index ].path, index ]]
      end

      # http://stackoverflow.com/questions/3482814/sorting-list-of-string-paths-in-vb-net
      sorted_folders.sort! do |first,second| 
        a = first[0]
        b = second[0]

        # use :: operator because gollum defines its own conflicting File class
        dir_compare = ::File.dirname(a) <=> ::File.dirname(b)

        # Sort based on directory name unless they're equal (0) in
        # which case sort based on file name.
        if dir_compare == 0
          ::File.basename(a) <=> ::File.basename(b)
        else
          dir_compare
        end
      end

      # keep track of folder depth, 0 = at root.
      cwd_array = []
      changed = false

      # process rest of folders
      0.upto(sorted_folders.size - 1) do | index |
          page =  @pages[ sorted_folders[ index ][1] ]
          path = page.path
          folder = ::File.dirname path

          tmp_array = folder.split('/')

          0.upto(tmp_array.size - 1) do |index|
            if cwd_array[index].nil? || changed
              html += new_sub_folder tmp_array[index]
              next
            end

            if cwd_array[index] != tmp_array[index]
              changed = true
              index.upto(cwd_array.size - 1) do |i|
                html += end_folder
              end
              html += new_sub_folder tmp_array[index]
            end
          end

          html += new_page page
          cwd_array = tmp_array
          changed = false
      end

      # return the completed html
      enclose_tree html
    end # end render_files
  end # end FileView class
end # end Gollum module
