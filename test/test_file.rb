require File.join(File.dirname(__FILE__), *%w[helper])

context "File" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "new file" do
    file = Gollum::File.new(@wiki)
    assert_nil file.raw_data
  end

  test "existing file" do
    file = @wiki.file("Mordor/todo.txt")
    assert_equal "[ ] Write section on Ents\n", file.raw_data
    assert_equal @wiki.repo.commits.first.id, file.version.id
  end
end