# ~*~ encoding: utf-8 ~*~
path = File.join(File.dirname(__FILE__), "helper") 
require File.expand_path(path)

context "File" do
  setup do
    @wiki = Gollum::Wiki.new(testpath("examples/lotr.git"))
  end

  test "new file" do
    file = Gollum::File.new(@wiki)
    assert_nil file.raw_data
  end

  test "existing file" do
    commit = @wiki.repo.commits.first
    file   = @wiki.file("Mordor/todo.txt")
    assert_equal "[ ] Write section on Ents\n", file.raw_data
    assert_equal 'todo.txt',         file.name
    assert_equal commit.id,          file.version.id
    assert_equal commit.author.name, file.version.author.name
  end

  test "accessing tree" do
    assert_nil @wiki.file("Mordor")
  end
end