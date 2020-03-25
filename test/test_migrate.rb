# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

# Original contents of Subdir/Foo.md:
# waa
# [[Samwi]]
# [[samwise gamgee.mediaWiki]]
# [[Samwise Gamgee.mediawiki]]
# [[Samwise Gamgee]]
# [[Test|Samwise Gamgee#Anchor]]
# [[Waaa|Test]]
# [[Zaa]]

# Contents of Subdir/Foo.md after successful tag migration
result = <<EOF
waa
[[Samwi]]
[[/Samwise Gamgee.mediawiki]]
[[/Samwise Gamgee.mediawiki]]
[[/Samwise Gamgee.md]]
[[Test|/Samwise Gamgee.md#Anchor]]
[[Waaa|/Bar/Test.md]]
[[Subsub/Zaa.md]]
EOF

script_path = File.expand_path(File.join(File.dirname(__FILE__), '../', 'bin', 'gollum-migrate-tags'))

unless ENV['TRAVIS']

  context '4.x -> 5.x tag migrator' do
    include Rack::Test::Methods

    setup do
      @path = cloned_testpath("examples/lotr_migration.git")
    end
    
    test 'repair broken links' do
      PREFER_RELATIVE = true
      RUN_SILENT = true
      NO_DRY_RUN = true
      HYPHENATE = false
      
      Dir.chdir(@path) do
        load script_path
      end
      f = ::File.new(::File.join(@path, 'Subdir/Foo.md'), 'r')
      assert_equal result, f.read
    end
    
    test 'change spaced filenames to hyphenated filenames' do
      RUN_SILENT = true
      NO_DRY_RUN = true
      PREFER_RELATIVE = true
      HYPHENATE = true
    
      Dir.chdir(@path) do
        load script_path
      end
    
      f = ::File.new(::File.join(@path, 'Home.textile'), 'r')
      output = f.read
      assert_equal true, output.include?('[[Bilbo-Baggins.md]]')
      assert_equal true, output.include?('[[evil|Mordor/Eye-Of-Sauron.md]]')
    end

    teardown do
      FileUtils.rm_rf(@path)
    end
  end

end