require File.join(File.dirname(__FILE__), *%w[helper])

context "Site" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/test_site.git"))
    @site = Gollum::Site.new(@wiki,
                             {:output_path => testpath("examples/site")})
  end

  test "generate static site" do
    @site.generate("master")
    assert_equal(["/Home",
                  "/Page1",
                  "/Page2",
                  "/static",
                  "/static/static.jpg",
                  "/static/static.txt"],
                 Dir[@site.output_path + "/**/*"].map { |f| f.sub(@site.output_path, "") })
  end

  teardown do
    FileUtils.rm_r(@site.output_path)
  end
end
