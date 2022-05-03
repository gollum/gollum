# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

def load_script(**args)
  settings = {
    :run_silent => true,
    :no_dry_run => true,
    :prefer_relative => true,
    :hyphenate => false,
    :page_file_dir => nil,
  }.merge(args)

  settings.each do |setting, val|
    variable_name = :"@@#{setting.to_s}"

    unless Object.class_variable_defined?(variable_name) && Object.class_variable_get(variable_name) == val
      Object.class_variable_set(variable_name, val)
    end
  end

  script_path = File.expand_path(File.join(File.dirname(__FILE__), '../', 'bin', 'gollum-migrate-tags'))

  Dir.chdir(@path) do
    load script_path
  end
end

context '4.x -> 5.x tag migrator' do
  include Rack::Test::Methods

  setup do
    @path = cloned_testpath("examples/lotr_migration.git")
  end

  test 'repair broken links' do
    # The original contents of Subdir/Foo.md:
    #
    # waa
    # [[Samwi]]
    # [[samwise gamgee.mediaWiki]]
    # [[Samwise Gamgee.mediawiki]]
    # [[Samwise Gamgee]]
    # [[Test|Samwise Gamgee#Anchor]]
    # [[Waaa|Test]]
    # [[Zaa]]
    #
    # The contents will be updated after running the migration script.
    load_script

    file = ::File.new(::File.join(@path, 'Subdir/Foo.md'), 'r')
    assert_equal <<~FILE_CONTENTS, file.read
      waa
      [[Samwi]]
      [[/Samwise Gamgee.mediawiki]]
      [[/Samwise Gamgee.mediawiki]]
      [[/Samwise Gamgee.md]]
      [[Test|/Samwise Gamgee.md#Anchor]]
      [[Waaa|/Bar/Test.md]]
      [[Subsub/Zaa.md]]
    FILE_CONTENTS
  end

  test 'change spaced filenames to hyphenated filenames' do
    load_script(hyphenate: true)

    f = ::File.new(::File.join(@path, 'Home.textile'), 'r')
    output = f.read
    assert_equal true, output.include?('[[Bilbo-Baggins.md]]')
    assert_equal true, output.include?('[[evil|Mordor/Eye-Of-Sauron.md]]')
  end

  test 'migration with page file dir' do
    load_script(page_file_dir: 'Subdir')

    f = ::File.new(::File.join(@path, 'Subdir/Foo.md'), 'r')
    output = f.read
    assert_equal true, output.include?('[[Subsub/Zaa.md]]')
    assert_equal true, output.include?('[[Samwi]]')
  end

  teardown do
    FileUtils.rm_rf(@path)
  end
end
