# ~*~ encoding: utf-8 ~*~
# stdlib
require 'digest/md5'
require 'digest/sha1'
require 'ostruct'

# external
require 'i18n'
require 'github/markup'
require 'rhino' if RUBY_PLATFORM == 'java'

# internal
require ::File.expand_path('../gollum/uri_encode_component', __FILE__)

module Gollum
  VERSION = '5.3.0'
  KEYBINDINGS = ['default', 'vim', 'emacs']
  
  ::I18n.available_locales = [:en]
  ::I18n.load_path = Dir[::File.expand_path("../gollum/locales",  __FILE__) + "/*.yml"]

  def self.assets_path
    ::File.expand_path('gollum/public', ::File.dirname(__FILE__))
  end

  class TemplateFilter
    @@filters = {}

    def self.add_filter(pattern, &replacement)
      @@filters[pattern] = replacement
    end

    def self.apply_filters(wiki_page, data)
      @@filters.each do |pattern, replacement|
        params = replacement.parameters.length == 0 ? nil : wiki_page
        data.gsub!(pattern, replacement.call(*params))
      end
      data
    end
  end
end
