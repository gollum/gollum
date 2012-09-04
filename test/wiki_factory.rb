class WikiFactory
  def self.create p
    path = testpath "examples/test.git"
    Grit::Repo.init_bare(path)
    Gollum::Wiki.default_options = {:universal_toc => false}
    cleanup = Proc.new { FileUtils.rm_r File.join(File.dirname(__FILE__), *%w[examples test.git]) }
    wiki = Gollum::Wiki.new(path)
    return wiki, path, cleanup
  end
end
