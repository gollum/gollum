require 'rss'

class RSSView
  include Precious::Views::AppHelpers
  include Precious::Views::RouteHelpers

  attr_reader :base_url

  def initialize(base_url, wiki_title, url, changes)
    @base_url = base_url
    @wiki_title = wiki_title
    @url = url
    @changes = changes
  end

  def render
    RSS::Maker.make('2.0') do |maker|
      maker.channel.author = 'Gollum Wiki'
      maker.channel.description = "Latest Changes in #{@wiki_title}"
      maker.channel.link = latest_changes_url
      maker.channel.title = "#{@wiki_title} Latest Changes"
      maker.channel.updated = @changes.first.authored_date

      @changes.each do |change|
        maker.items.new_item do |item|
          item.description = feed_item_description(change)
          item.link = latest_changes_url
          item.title = feed_item_title(change)
          item.updated = change.authored_date
        end
      end
    end.to_s
  end

  private

  def feed_item_commit_body(change)
    body = change.message.lines[1..-1].join
    body = body.split(/\n{2}/).map { |paragraph| "<p>#{paragraph}</p>" }.join
    body.gsub!(/\n/, ' ')
    body
  end

  def feed_item_description(change)
    ERB.new(<<~HTML_PARTIAL)
      <%= feed_item_commit_body(change) %>
      Committed by: <a href="mailto:<%= change.author.email %>">
        <%= change.author.name %>
      </a><br />
      Commit ID: <%= change.id[0..6] %><br /><br />
      <%= feed_item_files(change) %>
    HTML_PARTIAL
      .result(binding)
  end

  def feed_item_files(change)
    file_list = change.stats.files.map { |change_files|
      [
        change_files[:old_file],
        change_files[:new_file]
      ].compact
    }

    ERB.new(<<~HTML_PARTIAL)
      Affected files: <ul>
        <% file_list.each do |change_files| %>
          <% change_files.each do |file| %>
            <% file_href = "%s%s/%s" % [@url, page_route(file), change.id] %>
            <li><a href="<%= file_href %>"><%= file %></a></li>
          <% end %>
        <% end %>
      </ul>
    HTML_PARTIAL
      .result(binding)
  end

  def feed_item_title(change)
    change.message.lines.first.strip
  end

  def latest_changes_url
    "%s%s" % [@url, latest_changes_path]
  end
end
