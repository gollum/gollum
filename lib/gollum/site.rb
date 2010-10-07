module Gollum
  class Site
    attr_reader :output_path

    def initialize(wiki, options = {})
      @wiki = wiki
      @output_path = options[:output_path] || "_site"
    end

    # Public: generate a static site
    #
    # version - The String version ID to generate (default: "master").
    #
    def generate(version = 'master')
      ::Dir.mkdir(@output_path) unless ::File.exists? @output_path

      layouts = {}
      items = @wiki.tree_map_for(version).inject([]) do |list, entry|
        if entry.name =~ /^_Footer./
          # Ignore
        elsif entry.name == "_Layout.html"
          layout = ::Liquid::Template.parse(entry.blob(@wiki.repo).data)
          layouts[::File.dirname(entry.path)] = layout
        elsif @wiki.page_class.valid_page_name?(entry.name)
          sha = @wiki.ref_map[version] || version
          page = entry.page(@wiki, @wiki.repo.commit(sha))
          list << page
        else
          list << entry
        end
        list
      end

      items.each do |item|
        if item.is_a?(@wiki.page_class)
          path = ::File.join(@output_path, @wiki.page_class.cname(item.name))
          layout = get_layout(layouts, ::File.dirname(item.path))
          data = render_page(item, layout)
        else
          path = ::File.join(@output_path, item.path)
          ::FileUtils.mkdir_p(::File.dirname(path))
          data = item.blob(@wiki.repo).data
        end
        f = ::File.new(path, "w")
        f.write(data)
        f.close
      end
    end

    def get_layout(layouts, path)
      if path == ""
        layouts["."]
      else
        layouts[path] or get_layout(layouts, path.split("/")[0..-2].join("/"))
      end
    end

    def render_page(page, layout=nil)
      if layout.nil?
        return page.formatted_data
      else
        return layout.render( 'page' => page_to_liquid(page),
                              'wiki' => wiki_to_liquid(page.wiki))
      end
    end

    def page_to_liquid(page)
      {"content" => page.formatted_data,
        "title" => page.title,
        "format" => page.format.to_s,
        "author" => page.version.author.name,
        "date" => page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S")}
    end

    def wiki_to_liquid(wiki)
      {"base_path" => wiki.base_path}
    end
  end
end
