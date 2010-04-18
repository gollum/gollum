require File.join(File.dirname(__FILE__), *%w[helper])

context "Markup" do
  test "page link" do
    data = "a [[Bilbo Baggins]] b"
    output = Gollum::Markup.new("x.md", data).render
    assert_equal %{<p>a <a href="Bilbo-Baggins">Bilbo Baggins</a> b</p>\n}, output
  end
end
