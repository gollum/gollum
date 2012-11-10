# ~*~ encoding: utf-8 ~*~
module Gollum
=begin
  FileView requires that:
    - All files in root dir are processed first
    - Then all the folders are sorted and processed
=end
  class FileView
    # common use cases:
    # set pages to wiki.pages and show_all to false
    # set pages to wiki.pages + wiki.files and show_all to true
    def initialize pages, options = {}
      @pages = pages
      @show_all = options[:show_all] || false
      @checked = options[:collapse_tree] ? '' : "checked"
    end

    def enclose_tree string
      %Q(<ol class="tree">\n) + string + %Q(</ol>)
    end

    def new_page page
      name = page.name
      url  = url_for_page page
      %Q(  <li class="file"><a href="#{url}"><span class="icon"></span>#{name}</a></li>)
    end

    def new_folder folder_path
      new_sub_folder folder_path
    end

    def new_sub_folder path
      <<-HTML
      <li>
        <label>#{path}</label> <input type="checkbox" #{@checked} />
        <ol>
      HTML
    end

    def end_folder
      "</ol></li>\n"
    end

    def url_for_page page
      url = ''
      if @show_all
        # Remove ext for valid pages.
        filename = page.filename
        filename = Page::valid_page_name?(filename) ? filename.chomp(::File.extname(filename)) : filename

        url = ::File.join(::File.dirname(page.path), filename)
      else
        url = ::File.join(::File.dirname(page.path), page.filename_stripped)
      end
      url = url[2..-1] if url[0,2] == './'
      url
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
        html += <<-HTML
        <li>
          <label>#{::File.dirname(page.path)}</label> <input type="checkbox" #{@checked} />
          <ol>
          #{new_page page}
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
      (0...sorted_folders.size).each do | index |
          page =  @pages[ sorted_folders[ index ][ 1 ] ]
          path = page.path
          folder = ::File.dirname path

          tmp_array = folder.split '/'

          (0...tmp_array.size).each do | index |
            if cwd_array[ index ].nil? || changed
              html += new_sub_folder tmp_array[ index ]
              next
            end

            if cwd_array[ index ] != tmp_array[ index ]
              changed = true
              (cwd_array.size - index).times do
                html += end_folder
              end
              html += new_sub_folder tmp_array[ index ]
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
