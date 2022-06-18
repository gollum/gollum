# ~*~ encoding: utf-8 ~*~
require 'gemojione'

module Precious
  module Helpers

    EMOJI_PATHNAME = Pathname.new(Gemojione.images_path).freeze
    
    def find_per_page_upload_subdir(referer, host_with_port, base_path)
      base = base_path ? remove_leading_and_trailing_slashes(base_path) : ''
      dir = referer.match(/^https?:\/\/#{host_with_port}\/#{base}\/?(.*)/)[1]
      
      # remove gollum/* subpath if necessary
      dir.sub!(/^gollum\/[-\w]+\//, '')
      # remove file extension
      dir.sub!(/#{::File.extname(dir)}$/, '')
      # revert escaped whitespaces
      dir.gsub!(/%20/, ' ')
      
      return ::File.join('uploads', dir)
    end

    def sanitize_empty_params(param)
      [nil, ''].include?(param) ? nil : CGI.unescape(param)
    end

    def strip_page_name(name)
      # Check if name already has a format extension, and if so, strip it.
      Gollum::Page.valid_extension?(name) ? Gollum::Page.strip_filename(name) : name
    end
    
    def remove_leading_and_trailing_slashes(str)
      str.sub(%r{^(/+)}, '').sub(%r{/+$}, '')
    end

    # Remove all slashes from the start of string.
    # Remove all double slashes
    def clean_url(url)
      return url if url.nil?
      url.gsub('%2F', '/').gsub(%r{/{2,}}, '/').gsub(%r{^/}, '')
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
    
    def not_found_proc
      not_found_msg = 'Not found.'
      Proc.new {[404, {'Content-Type' => 'text/html', 'Content-Length' => not_found_msg.length.to_s}, [not_found_msg]]}
    end
    
    def emoji(name)
      if emoji = Gemojione.index.find_by_name(name)
        IO.read(EMOJI_PATHNAME.join("#{emoji['unicode'].downcase}.png"))
      else
        fail ArgumentError, "emoji `#{name}' not found"
      end
    end
  end
end
