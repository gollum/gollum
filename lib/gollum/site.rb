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

      @wiki.tree_map_for(version).each do |entry|
        if entry.name =~ /^_Footer./
          # Skip
        elsif @wiki.page_class.valid_page_name?(entry.name)
          sha = @wiki.ref_map[version] || version
          page = entry.page(@wiki, @wiki.repo.commit(sha))
          path = ::File.join(@output_path, page.name)
          p = ::File.new(path, "w")
          p.write(page.formatted_data)
          p.close
        else
          path = ::File.join(@output_path, entry.path)
          ::FileUtils.mkdir_p(::File.dirname(path))
          f = ::File.new(path, "w")
          f.write(entry.blob(@wiki.repo).data)
          f.close
        end
      end
    end
  end
end
