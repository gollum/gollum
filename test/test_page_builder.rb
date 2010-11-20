require File.join(File.dirname(__FILE__), *%w[helper])

context "PageBuilder" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
    @default_destination = testpath("static/default")
    FileUtils.rm_rf @default_destination
  end

  test "builds a default page" do
    @wiki.builder.publish_to @default_destination
    assert File.directory?(@default_destination)
    assert File.exist?("#{@default_destination}/index.html")
    assert File.exist?("#{@default_destination}/Bilbo-Baggins.html")
    assert File.exist?("#{@default_destination}/Eye-Of-Sauron.html")
    assert File.exist?("#{@default_destination}/My-Precious.html")
  end
end