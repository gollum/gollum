require File.join(File.dirname(__FILE__), *%w[helper])

context "PageBuilder" do
  setup do
    @asset_dir = testpath("examples/builder")
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
    @builder = @wiki.builder
    @default_destination = testpath("static/default")
    FileUtils.rm_rf @default_destination
  end

  test "builds a default page" do
    @builder.publish_to @default_destination
    assert File.directory?(@default_destination)
    assert File.exist?("#{@default_destination}/css/gollum.css")
    assert File.exist?("#{@default_destination}/css/template.css")
    assert File.exist?("#{@default_destination}/index.html")
    assert File.exist?("#{@default_destination}/Bilbo-Baggins.html")
    assert File.exist?("#{@default_destination}/Eye-Of-Sauron.html")
    assert File.exist?("#{@default_destination}/My-Precious.html")
  end

  test "builds a page with assets in a custom location" do
    builder = @wiki.builder :add_assets => ["#{@asset_dir}/foo.js"]
    builder.publish_to @default_destination
    assert File.exist?("#{@default_destination}/css/gollum.css")
    assert File.exist?("#{@default_destination}/css/template.css")
    assert File.exist?("#{@default_destination}/js/foo.js")
  end

  test "builder can replace assets list" do
    builder = @wiki.builder :assets => %w(abc.def)
    assert_equal %w(abc.def), builder.assets
  end

  test "builder can set custom template paths" do
    builder = @wiki.builder \
      :layout_template => 'abc.def',
      :page_template   => 'ghi.jkl'
    assert_match 'abc', builder.layout_template
    assert_match 'ghi', builder.page_template
  end
end
