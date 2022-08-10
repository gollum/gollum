require_relative "helper"

context "Precious::Views::RSS" do
  # Simplistically mimics a `Gollum::Git::Actor` object.
  #
  MockAuthor = Struct.new(:name, :email)

  # Simplistically mimics a `Gollum::Git::Commit` object.
  #
  MockChange = Class.new do
    def author
      MockAuthor.new("committer name", "email@example.com")
    end

    def authored_date
      Time.new(1999, 01, 01, 0, 0)
    end

    def files
      ["file 1", "file 2"]
    end

    def id
      "f0f0f0f0"
    end

    def message
      <<~COMMIT_MESSAGE
        Multi-line commit message

        This commit is multiple lines long so we can test how this is
        rendered in the feed.

        Git's documentation says that the first line of a commit should
        be 50 characters or fewer, and the rest of the commit body's
        lines should not exceed 72 characters in length.
      COMMIT_MESSAGE
    end

    def stats
      OpenStruct.new(files: [{old_file: "old", new_file: "new"}])
    end
  end

  test "renders a valid RSS feed" do
    feed = RSSView.new(
      "/",
      "Wiki Name",
      "https://example.com",
      [MockChange.new]
    ).render

    # Assert that we have required RSS feed elements.
    #
    assert_match "<?xml version=\"1.0\" encoding=\"UTF-8\"?>",              feed
    assert_match /<rss version=\"2.0\"(.*)<\/rss>/m,                        feed
    assert_match /<channel>(.*)<\/channel>/m,                               feed

    # Assert that we have feed metadata.
    #
    assert_match "<title>Wiki Name Latest Changes</title>",                 feed
    assert_match "<link>https://example.com/gollum/latest_changes</link>",  feed
    assert_match "<description>Latest Changes in Wiki Name</description>",  feed
    assert_match /<pubDate>(.*)<\/pubDate>/,                                feed

    # Assert that we have an item in our feed.
    #
    assert_match /<item>(.*)<\/item>/m,                                     feed

    # And it has a title.
    #
    assert_match "<title>Multi-line commit message</title>",                feed

    # Assert that the description contains expected content.
    #
    assert_match /<description>(.*)<\/description>/m,                       feed
    assert_match /&lt;p&gt; This commit(.*)&lt;\/p&gt;/,                    feed
    assert_match /&lt;p&gt;Git's documentation(.*)&lt;\/p&gt;/,             feed

    # Assert that the description contains information about the commit.
    # i.e.:
    #
    #  <a href="mailto:email@example.com">committer name</a>
    #
    #  Commit ID: f0f0f0f0
    #
    assert_match /Committed by: /,                                          feed
    assert_match /\&lt;a href=\&quot;mailto:email@example.com\&quot;\&gt;/, feed
    assert_match /\&gt;\n  committer name\n\&lt;\/a&gt;/,                   feed
    assert_match "Commit ID: f0f0f0f",                                      feed

    # Assert that affected files include links to commits, i.e.:
    #
    #  <a href="https://example.com/old/f0f0f0f0">new</a>
    #
    assert_match /Affected files: /,                                        feed
    assert_match /\&lt;a href=\&quot;https:\/\/example.com\/old\/f0f0f0f0\&quot;/,
                                                                            feed
    assert_match /f0f0f0f0&quot;&gt;new&lt;\/a&gt;/,                        feed
  end
end
