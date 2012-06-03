# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/file_view', __FILE__

class FakePage
  def initialize filepath
    @filepath = filepath  
  end
  
  def path
    return @filepath
  end

  # From page.rb
  def name
    self.class.canonicalize_filename @filepath
  end

  # From page.rb
  def self.strip_filename filename
    ::File.basename( filename, ::File.extname( filename ))
  end

  # From page.rb
  def self.canonicalize_filename filename
    strip_filename(filename).gsub('-', ' ')
  end
end

class FakePages
  def initialize filepath_array
    @array = filepath_array.map { | filepath | FakePage.new filepath }
  end

  def size
    @array.size
  end
  
  def [] index
    @array[ index ]
  end
end

def view pages
  Gollum::FileView.new( pages ).render_files
end

@@test_path = File.expand_path( '../file_view/' , __FILE__ ) + '/'

def read file
  File.read @@test_path + file + '.txt'
end

# For creating expected files.
def write file, content
  File.open(@@test_path + file + '.txt', 'w') do | f |
    f.write content
  end
end

# Test Notes
# root files must be before any folders.
# Home.md => file at root folder
# docs/sanitization.md => file within folder
context 'file_view' do
  test 'one file' do
    pages = FakePages.new [ '0.md' ]
    expected = read '1_file'
    actual = view pages
    assert_equal expected, actual
  end

  test 'one folder' do
    pages = FakePages.new [ 'folder0/' ]
    expected = read '1_folder'
    actual = view pages
    assert_equal expected, actual
  end

  test 'one file with one folder' do
    pages = FakePages.new [ 'folder0/0.md' ]
    expected = read '1_file_1_folder'
    actual = view pages
    assert_equal expected, actual
  end

  test 'two files with two folders' do
    pages = FakePages.new [ 'folder0/0.md', 'folder1/1.md' ]
    expected = read '2_files_2_folders'
    actual = view pages
    assert_equal expected, actual
  end

  test 'two files with two folders and one root file' do
    pages = FakePages.new [ 'root.md', 'folder0/0.md', 'folder1/1.md' ]
    expected = read '2_files_2_folders_1_root'
    actual = view pages
    assert_equal expected, actual
  end

  test 'nested folders' do
    pages = FakePages.new [ 'folder0/folder1/folder2/0.md', 'folder0/folder1/folder3/1.md', 'folder4/2.md' ]
    expected = read 'nested_folders'
    actual = view pages
    assert_equal expected, actual
  end
end # context
