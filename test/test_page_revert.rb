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

  test "reverts single commit" do
    page1 = @wiki.page('B')
    sha   = @wiki.revert_page(page1, '7c45b5f16ff3bae2a0063191ef832701214d4df5')
    page2 = @wiki.page('B')
    assert_equal sha,       page2.version.sha
    assert_equal "INITIAL", page2.raw_data.strip
  end

  test "reverts multiple commits" do
    page1 = @wiki.page('A')
    sha   = @wiki.revert_page(page1, '302a5491a9a5ba12c7652ac831a44961afa312d2^', 'b26b791cb7917c4f37dd9cb4d1e0efb24ac4d26f')
    page2 = @wiki.page('A')
    assert_equal sha,       page2.version.sha
    assert_equal "INITIAL", page2.raw_data.strip
  end

  test "cannot revert conflicting commit" do
    page1 = @wiki.page('A')
    assert_equal false, @wiki.revert_page(page1, '302a5491a9a5ba12c7652ac831a44961afa312d2')
  end
end
