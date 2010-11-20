require 'mustache'

module Gollum
  class PageBuilder
    def initialize(wiki)
      @wiki = wiki
    end

    # Public: Publishes the wiki to the given filesystem path.
    #
    # destination - Optional String path to the directory that the files 
    #               should be written.
    #
    # Returns nothing.
    def publish_to(destination)
      FileUtils.mkdir_p(destination)
      layout    = Mustache.templateify \
                    IO.read("#{DEFAULT_TEMPLATES_PATH}/layout.mustache")
      template  = Mustache.templateify \
                    IO.read("#{DEFAULT_TEMPLATES_PATH}/page.mustache")
      @wiki.pages.each do |page|
        page_html = Mustache.render template,
          :title   => page.title,
          :content => page.formatted_data,
          :author  => page.version.author.name,
          :date    => page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S"),
          :raw     => page.raw_data
        layout_html = Mustache.render layout,
          :title => page.title,
          :yield => page_html
        filename = "#{page.name =~ /^home$/i ? :index : Page.cname(page.name)}.html"
        fullpath = ::File.join(destination, filename)
        ::File.open fullpath, 'w' do |f|
          f << layout_html
        end
      end
      copy_assets_to(destination)
    end

    # Copies the default CSS files to the given destination.
    #
    # destination - Optional String path to the directory that the files 
    #               should be written.
    #
    # Returns nothing.
    def copy_assets_to(destination)
      css_path = "#{destination}/css"
      FileUtils.mkdir_p(css_path)
      %w( gollum template ).each do |css_file|
        FileUtils.cp \
          "#{DEFAULT_TEMPLATES_PATH}/#{css_file}.css",
          "#{css_path}/#{css_file}.css"
      end
    end

    DEFAULT_TEMPLATES_PATH = ::File.join(::File.dirname(__FILE__), 'page_builder')
  end
end