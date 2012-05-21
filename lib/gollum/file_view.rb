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
      %Q(<ol class="tree">\n) + string + %Q(\n</ol>)
    end

    def new_page page
      name = page.name
      %Q(  <li class="file"><a href="#{name}">#{name}</a></li>\n)
    end

    def new_folder page
      new_sub_folder ::File.dirname(page.path), page.name
    end

    def new_sub_folder path, name
      <<-HTML
      <li>
        <label>#{path}</label> <input type="checkbox" checked />
        <ol>
          <li class="file"><a href="#{name}">#{name}</a></li>
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
        path = @pages[ folder_start ]
        name = page.name
        html += <<-HTML
        <li>
          <label>#{::File.dirname(path)}</label> <input type="checkbox" checked />
          <ol>
            <li class="file"><a href="#{name}">#{name}</a></li>
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

      # Process first folder
      page = @pages[ sorted_folders[ 0 ][1] ]
      html += new_folder page

      last_folder =  ::File.dirname page.path # define last_folder

      # keep track of folder depth, 0 = at root.
      depth = 0

      # process rest of folders
      1.upto(sorted_folders.size - 1) do | index |
          page =  @pages[ sorted_folders[ index ][1] ]
          path = page.path
          folder = ::File.dirname path

          if last_folder == folder
            # same folder
            html += new_page page
          elsif folder.include?('/')
            # check if we're going up or down a depth level
            if last_folder.scan('/').size > folder.scan('/').size
              # end tag for 1 subfolder & 1 parent folder
              # so emit 2 end tags
              2.times { html += end_folder; }
              depth -= 1
            else
              depth += 1
            end

            # subfolder
            html += new_sub_folder ::File.dirname(page.path).split('/').last, page.name
          else
            # depth+1 because we need an additional end_folder
            (depth+1).times { html += end_folder; }
            depth = 0
            # New root folder
            html += new_folder page
          end

          last_folder = folder
      end

      # Process last folder's ending tags.
      (depth+1).times {       
        depth.times { html += end_folder; }
        depth = 0
      }

      # return the completed html
      enclose_tree html
    end # end render_files
  end # end FileView class
end # end Gollum module
