# ~*~ encoding: utf-8 ~*~
module Gollum
  module Pagination
    def self.included(klass)
      klass.extend ClassMethods
      class << klass
        # Default Integer max count of items to return in git commands.
        attr_accessor :per_page
      end
      klass.per_page = 30
    end

    module ClassMethods
      # Turns a page number into an offset number for the git skip option.
      #
      # page - Integer page number.
      #
      # Returns an Integer.
      def page_to_skip(page)
        ([1, page.to_i].max - 1) * per_page
      end

      # Fills in git-specific options for the log command using simple
      # pagination options.
      #
      # options - Hash of options:
      #           page - Optional Integer page number (default: 1)
      #           per_page - Optional Integer max count of items to return.
      #                      Defaults to #per_class class method.
      #
      # Returns Hash with :max_count and :skip keys.
      def log_pagination_options(options = {})
        skip = page_to_skip(options.delete(:page))
        options[:max_count] = [options.delete(:per_page).to_i, per_page].max
        options[:skip]      = skip if skip > 0
        options
      end
    end

    # Turns a page number into an offset number for the git skip option.
    #
    # page - Integer page number.
    #
    # Returns an Integer.
    def page_to_skip(page)
      self.class.page_to_skip(page)
    end

    # Fills in git-specific options for the log command using simple
    # pagination options.
    #
    # options - Hash of options:
    #           page - Optional Integer page number (default: 1)
    #           per_page - Optional Integer max count of items to return.
    #                      Defaults to #per_class class method.
    #
    # Returns Hash with :max_count and :skip keys.
    def log_pagination_options(options = {})
      self.class.log_pagination_options(options)
    end
  end
end
