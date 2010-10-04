require File.join(File.dirname(__FILE__), *%w[helper])

context "Site" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
    @site = Gollum::Site.new(@wiki,
                             {:output_path => testpath("examples/site")})
  end

  test "generate static site" do
    @site.generate("master")
    assert_equal(["/bilbo",
                  "/Bilbo Baggins",
                  "/Data.csv",
                  "/Eye Of Sauron",
                  "/Home",
                  "/Mordor",
                  "/Mordor/eye.jpg",
                  "/Mordor/todo.txt",
                  "/My Precious"],
                 Dir[@site.output_path + "/**/*"].map { |f| f.sub(@site.output_path, "") })
  end

  teardown do
    FileUtils.rm_r(@site.output_path)
  end
end
