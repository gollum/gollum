# ~*~ encoding: utf-8 ~*~
# stdlib
require 'digest/md5'
require 'digest/sha1'
require 'ostruct'

# external
require 'grit'
require File.expand_path('../gollum/grit_ext', __FILE__)
require 'github/markup'
require 'sanitize'

# internal
require File.expand_path('../gollum/git_access', __FILE__)
require File.expand_path('../gollum/committer', __FILE__)
require File.expand_path('../gollum/pagination', __FILE__)
require File.expand_path('../gollum/blob_entry', __FILE__)
require File.expand_path('../gollum/wiki', __FILE__)
require File.expand_path('../gollum/page', __FILE__)
require File.expand_path('../gollum/file', __FILE__)
require File.expand_path('../gollum/file_view', __FILE__)
require File.expand_path('../gollum/markup', __FILE__)
require File.expand_path('../gollum/markups', __FILE__)
require File.expand_path('../gollum/sanitization', __FILE__)
require File.expand_path('../gollum/web_sequence_diagram', __FILE__)
require File.expand_path('../gollum/frontend/uri_encode_component', __FILE__)

# Set ruby to UTF-8 mode
# This is required for Ruby 1.8.7 which gollum still supports.
$KCODE = 'U' if RUBY_VERSION[0,3] == '1.8'

module Gollum
  VERSION = '2.4.11'

  def self.assets_path
    ::File.expand_path('gollum/frontend/public', ::File.dirname(__FILE__))
  end

  class Error < StandardError; end

  class DuplicatePageError < Error
    attr_accessor :dir
    attr_accessor :existing_path
    attr_accessor :attempted_path

    def initialize(dir, existing, attempted, message = nil)
      @dir            = dir
      @existing_path  = existing
      @attempted_path = attempted
      super(message || "Cannot write #{@dir}/#{@attempted_path}, found #{@dir}/#{@existing_path}.")
    end
  end
end

