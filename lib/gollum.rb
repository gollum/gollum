# external
require 'grit'

# internal
require 'gollum/wiki'
require 'gollum/page'

module Gollum
  VERSION = '0.0.1'

  # Convert a human page name into a canonical page name.
  #
  # name - The String human page name.
  #
  # Examples
  #   Gollum.canonical_name("Bilbo Baggins")
  #   # => 'Bilbo-Baggins'
  #
  # Returns the String canonical name.
  def self.canonical_name(name)
    name.gsub(/ /, '-')
  end
end