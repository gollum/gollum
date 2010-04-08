require 'helper'

context "Page" do
  setup do
    @repo = Gollum::Repo.new("examples/lotr.git")
  end

  test "formatted page" do
    page = @repo.formatted_page('Bilbo-Baggins')
  end
end