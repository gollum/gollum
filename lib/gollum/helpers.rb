# ~*~ encoding: utf-8 ~*~
require 'gemojione'

module Precious
  module Helpers

    EMOJI_PATHNAME = Pathname.new(Gemojione.images_path).freeze

    # Extract the path string that Gollum::Wiki expects
    def extract_path(path)
      dirname = Pathname.new(path).cleanpath.dirname.to_s
      dirname == '.' ? nil : dirname
    end

    def extract_path_elements(path)
      pathname = Pathname.new(path).cleanpath
      dirname = ::File.join('/', pathname.dirname.to_s)
      dirname = '/' if dirname == '.'
      fullpath = pathname.to_s
      fullpath = '/' if fullpath = '.'
      return fullpath, dirname, pathname.basename.to_s, pathname.extname.to_s
    end

    def sanitize_empty_params(param)
      [nil, ''].include?(param) ? nil : CGI.unescape(param)
    end

    # Remove all slashes from the start of string.
    # Remove all double slashes
    def clean_url url
      return url if url.nil?
      url.gsub('%2F', '/').gsub(/^\/+/, '').gsub('//', '/')
    end

    def forbid(msg = "Forbidden. This wiki is set to no-edit mode.")
      @message = msg
      status 403
      halt mustache :error
    end

    def not_found(msg = nil)
      @message = msg || "The requested page does not exist."
      status 404
      return mustache :error
    end

    def emoji(name)
      if emoji = Gemojione.index.find_by_name(name)
        IO.read(EMOJI_PATHNAME.join("#{emoji['unicode']}.png"))
      else
        fail ArgumentError, "emoji `#{name}' not found"
      end
    end

  end
end
