# ~*~ encoding: utf-8 ~*~
module Precious
  module Helpers
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
      ::File.basename(file_path)
    end

    def sanitize_empty_params(param)
      [nil,''].include?(param) ? nil : CGI.unescape(param)
    end

    # Remove all slashes from the start of string.
    def clean_url url
      return url if url.nil?
      url.gsub('%2F','/').gsub(/^\/+/,'')
    end

    def trim_leading_slash url
      return url if url.nil?
      url.gsub!('%2F','/')
      return '/' + url.gsub(/^\/+/,'') if url[0,1] == '/'
      url
    end
  end
end
