module Precious
  module HasPage
    def path
      @page.url_path
    end

    def escaped_url_path
      @page.escaped_url_path
    end

    def format
      @page.format.to_s
    end

    def id
      @page.sha
    end

    def full_url_path
      ::File.join(@base_url, escaped_url_path)
    end
  end
end
