# stdlib
require 'digest/md5'
require 'ostruct'

# external
require 'grit'
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
require File.expand_path('../gollum/markup', __FILE__)
require File.expand_path('../gollum/sanitization', __FILE__)
require File.expand_path('../gollum/tex', __FILE__)

module Gollum
  VERSION = '1.3.1'

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

  def Gollum.split_url(name)
      #require 'ruby-debug/debugger'
      pathlist = name.split(IO::File::SEPARATOR)
      dir = pathlist[0..-2].join('/')
      stripped_name = pathlist[-1]
      return dir + '/', Gollum::Page.cname(stripped_name)
  end
end

