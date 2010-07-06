module Gollum
  module Pagination
    def self.included(klass)
      klass.extend ClassMethods
      class << klass
        attr_accessor :per_page
      end
      klass.per_page = 30
    end

    module ClassMethods
      def page_to_skip(page)
        ([1, page.to_i].max - 1) * per_page
      end

      def log_pagination_options(options = {})
        skip = page_to_skip(options.delete(:page))
        options[:max_count] = [options.delete(:per_page).to_i, per_page].max
        options[:skip]      = skip if skip > 0
        options
      end
    end

    def page_to_skip(page)
      self.class.page_to_skip(page)
    end

    def log_pagination_options(options = {})
      self.class.log_pagination_options(options)
    end
  end
end