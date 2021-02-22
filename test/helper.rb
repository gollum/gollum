require 'rubygems'
require 'rack/test'
require 'test/unit'
require 'shoulda'
require 'mocha/setup'
require 'fileutils'
require 'minitest/reporters'
require 'minitest/spec'
require 'twitter_cldr'
require 'tmpdir'

# Silence locale validation warning
require 'i18n'
I18n.enforce_available_locales = false

MiniTest::Reporters.use!

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift(File.join(dir, '..', 'lib'))
$LOAD_PATH.unshift(dir)

module Gollum
end
if ENV['GIT_ADAPTER']
  Gollum::GIT_ADAPTER = ENV['GIT_ADAPTER']
else
  Gollum::GIT_ADAPTER = RUBY_PLATFORM == 'java' ? 'rjgit' : 'rugged'
end

ENV['RACK_ENV'] = 'test'
require 'gollum'
require 'gollum/app'

# Disable the metadata feature
$METADATA = false

# Make sure we're in the test dir, the tests expect that to be the current
# directory.
TEST_DIR  = File.join(File.dirname(__FILE__), *%w[.])

def testpath(path)
  File.join(TEST_DIR, path)
end

def cloned_testpath(path, bare = false)
  repo   = File.expand_path(testpath(path))
  tmpdir = Dir.mktmpdir(self.class.name)
  bare   = bare ? "--bare" : ""
  redirect = Gem.win_platform? ? '' : '2>/dev/null'
  %x{git clone #{bare} '#{repo}' #{tmpdir} #{redirect}}
  tmpdir
end

def commit_details
  { :message => "Did something at #{Time.now}",
    :name    => "Tom Preston-Werner",
    :email   => "tom@github.com" }
end

def normal(text)
  text.gsub!(' ', '')
  text.gsub!("\n", '')
  text
end

# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
# file:lib/test/spec/mini.rb
def context(*args, &block)
  return super unless (name = args.first) && block
  require 'test/unit'
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Test::Unit::TestCase) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/, '_')}", &block) if block
    end

    def self.xtest(*args)
    end

    def self.setup(&block)
      define_method(:setup, &block)
    end

    def self.teardown(&block)
      define_method(:teardown, &block)
    end
  end
  (
  class << klass;
    self
  end).send(:define_method, :name) { name.gsub(/\W/, '_') }
  $contexts << klass
  klass.class_eval &block
end

$contexts = []
