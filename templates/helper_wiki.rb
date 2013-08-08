class WikiFactory
  def self.create p
    examples = testpath "examples"
    path = File.join(examples, "test.git")
    FileUtils.cp_r File.join(examples, "empty.git"), path, :remove_destination => true
    Gollum::Wiki.default_options = {:universal_toc => false}
    cleanup = Proc.new { FileUtils.rm_r File.join(File.dirname(__FILE__), *%w[examples test.git]) }
    Gollum::Wiki.new(@path), @path, cleanup
  end
end
