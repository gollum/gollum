# stdlib
require 'digest/md5'
require 'ostruct'

# external
require 'grit'
require 'github/markup'
require 'sanitize'

# ruby 1.8 compatibility
require 'gollum/ruby1.8'

# internal
require 'gollum/git_access'
require 'gollum/pagination'
require 'gollum/blob_entry'
require 'gollum/wiki'
require 'gollum/page'
require 'gollum/file'
require 'gollum/markup'
require 'gollum/albino'
require 'gollum/sanitization'

module Gollum
  VERSION = '1.1.0'

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

