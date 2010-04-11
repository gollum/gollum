require File.join(File.dirname(__FILE__), *%w[helper])

context "File" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "new file" do
    file = Gollum::File.new(@wiki)
  end
end