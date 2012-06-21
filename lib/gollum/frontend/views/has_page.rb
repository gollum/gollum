module Precious
  module HasPage
    def path
      @page.path
    end

    def escaped_url_path
      @page.escaped_url_path
    end

    def format
      @page.format.to_s
    end
  end
end
