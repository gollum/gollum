require 'mustache'

module Gollum
  class PageBuilder
    class Markup < Gollum::Markup
      # Generate a page link for an anchor tag.
      #
      # link_name - CGI-escaped String name of the link.
      #
      # Returns a String link.
      def build_page_link(link_name)
        link_name << ".html"
      end
    end

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
      old_markup_class   = @wiki.markup_class
      @wiki.markup_class = Gollum::PageBuilder::Markup

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
        filename = "#{page.name =~ /^home$/i ? :index : @wiki.page_class.cname(page.name)}.html"
        fullpath = ::File.join(destination, filename)
        ::File.open fullpath, 'w' do |f|
          f << layout_html
        end
      end
      copy_assets_to(destination)
    ensure
      @wiki.markup_class = old_markup_class
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