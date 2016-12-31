# ~*~ encoding: utf-8 ~*~
require 'gemojione'

module Precious
  module Helpers

    EMOJI_PATHNAME = Pathname.new(Gemojione.images_path).freeze

    # Extract the path string that Gollum::Wiki expects
    def extract_path(file_path)
      return nil if file_path.nil?
      last_slash = file_path.rindex("/")
      if last_slash
        file_path[0, last_slash]
      end
    end

    # Extract the 'page' name from the file_path
    def extract_name(file_path)
      if file_path[-1, 1] == "/"
        return nil
      end

      # File.basename is too eager to please and will return the last
      # component of the path even if it ends with a directory separator.
      ::File.basename(file_path)
    end

    def sanitize_empty_params(param)
      [nil, ''].include?(param) ? nil : CGI.unescape(param)
    end

    # Ensure path begins with a single leading slash
    def clean_path(path)
      if path
        (path[0] != '/' ? path.insert(0, '/') : path).gsub(/\/{2,}/, '/')
      end
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
