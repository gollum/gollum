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

    attr_reader :assets,
      :layout_template,
      :page_template,
      :dir

    def initialize(wiki, options = {})
      @wiki   = wiki
      @assets = %w(gollum.css template.css)
      process_options(options)

      @dir             ||= DEFAULT_TEMPLATES_PATH
      @layout_template ||= "#{@dir}/layout.mustache"
      @page_template   ||= "#{@dir}/page.mustache"
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
      @page_view = @layout_view = nil

      FileUtils.mkdir_p(destination)

      @wiki.pages.each { |page| publish_page(page, destination) }

      copy_assets_to(destination)
    ensure
      @wiki.markup_class = old_markup_class
    end

    def inspect
      %(#<#{self.class} @wiki=#{@wiki.inspect}>)
    end

    def page_to_mustache(page)
      {
        :title   => page.title,
        :content => page.formatted_data,
        :author  => page.version.author.name,
        :date    => page.version.authored_date.strftime("%Y-%m-%d %H:%M:%S"),
        :raw     => page.raw_data
      }
    end

    def publish_page(page, destination)
      filename = "#{page.name =~ /^home$/i ? :index : @wiki.page_class.cname(page.name)}.html"
      fullpath = ::File.join(destination, filename)
      ::File.open fullpath, 'w' do |f|
        f << render_page(page)
      end
    end

    def render_page(page)
      data = page_to_mustache(page)
      page_html = Mustache.render(page_view, data)
      Mustache.render(layout_view, data.update(:yield => page_html))
    end

    def layout_view
      @layout_view ||= Mustache.templateify(IO.read(@layout_template))
    end

    def page_view
      @page_view ||= Mustache.templateify(IO.read(@page_template))
    end

    # Copies the default CSS files to the given destination.
    #
    # destination - Optional String path to the directory that the files
    #               should be written.
    #
    # Returns nothing.
    def copy_assets_to(destination)
      sort_assets.each do |ext, files|
        asset_path = "#{destination}/#{ext}"
        FileUtils.mkdir(asset_path)
        files.each do |file|
          file = "#{@dir}/#{file}" unless file['/']
          FileUtils.cp file, "#{asset_path}/#{::File.basename(file)}"
        end
      end
    end

    def sort_assets
      @assets.inject({}) do |memo, filename|
        ext  = ::File.extname(filename)
        key  = ext[1..-1].to_sym
        memo[key] ||= []
        memo[key]  << filename
        memo
      end
    end

    def process_options(options)
      if assets = options[:assets]
        @assets = assets
      elsif assets = options[:add_assets]
        @assets.push *assets
      end

      if layout = options[:layout_template]
        @layout_template = ::File.expand_path(layout)
      end

      if page = options[:page_template]
        @page_template = ::File.expand_path(page)
      end

      @dir = options[:dir]
    end

    DEFAULT_TEMPLATES_PATH = ::File.expand_path('../page_builder', __FILE__)
  end
end
