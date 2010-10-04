require File.join(File.dirname(__FILE__), *%w[helper])

context "Site" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/test_site.git"))
    @site = Gollum::Site.new(@wiki,
                             {:output_path => testpath("examples/site")})
    @site.generate("master")
  end

  test "generate static site" do
    assert_equal(["/Home",
                  "/Page1",
                  "/Page2",
                  "/static",
                  "/static/static.jpg",
                  "/static/static.txt"],
                 Dir[@site.output_path + "/**/*"].map { |f| f.sub(@site.output_path, "") })
  end

  test "render page with layout" do
    home_path = File.join(@site.output_path, "Home")
    assert_equal(["<html><p>Site test</p></html>\n"], File.open(home_path).readlines)
  end

  test "render page with layout from parent dir" do
    page_path = File.join(@site.output_path, "Page1")
    assert_equal(["<html><p>Site test</p></html>\n"], File.open(page_path).readlines)
  end

  test "render page with layout from sub dir" do
    page_path = File.join(@site.output_path, "Page2")
    assert_equal(["<html><body><p>Site test</p></body></html>\n"], File.open(page_path).readlines)
  end

  teardown do
    FileUtils.rm_r(@site.output_path)
  end
end
