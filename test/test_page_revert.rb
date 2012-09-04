# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), "helper"))

context "Page Reverting" do
  setup do
    @path = cloned_testpath("examples/revert.git")
    @wiki = Gollum::Wiki.new(@path)
  end

  teardown do
    FileUtils.rm_rf(@path)
  end

=begin
  # Grit is broken and this test fails often. See #363.
  test "reverts single commit" do
    page1 = @wiki.page("B")
    sha   = @wiki.revert_commit('7c45b5f16ff3bae2a0063191ef832701214d4df5')
    page2 = @wiki.page("B")
    assert_equal sha,       page2.version.sha
    assert_equal "INITIAL", body=page2.raw_data.strip
    assert_equal body, File.read(File.join(@path, "B.md")).strip
  end

  test "reverts single commit for a page" do
    page1 = nil
    while (page1 == nil)
      page1 = @wiki.page('B')
    end

    sha   = @wiki.revert_page(page1, '7c45b5f16ff3bae2a0063191ef832701214d4df5')
    
    page2 = nil
    while (page2 == nil)
      page2 = @wiki.page('B')
    end
    
    assert_equal sha,       page2.version.sha
    assert_equal "INITIAL", body=page2.raw_data.strip
    assert_equal body, File.read(File.join(@path, "B.md")).strip
  end

  test "reverts multiple commits for a page" do
    page1 = @wiki.page('A')
    sha   = @wiki.revert_page(page1, '302a5491a9a5ba12c7652ac831a44961afa312d2^', 'b26b791cb7917c4f37dd9cb4d1e0efb24ac4d26f')
    page2 = @wiki.page('A')
    assert_equal sha,       page2.version.sha
    assert_equal "INITIAL", body=page2.raw_data.strip
    assert_equal body, File.read(File.join(@path, "A.md")).strip
  end
=end

  test "cannot revert conflicting commit" do
    page1 = @wiki.page('A')
    assert_equal false, @wiki.revert_page(page1, '302a5491a9a5ba12c7652ac831a44961afa312d2')
  end
end
