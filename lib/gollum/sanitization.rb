module Gollum
  # Encapsulate sanitization options.
  #
  # This class does not yet support all options of Sanitize library.
  # See http://github.com/rgrove/sanitize/.
  class Sanitization
    # Default whitelisted elements.
    ELEMENTS = [
      'a', 'abbr', 'acronym', 'address', 'area', 'b', 'big',
      'blockquote', 'br', 'button', 'caption', 'center', 'cite',
      'code', 'col', 'colgroup', 'dd', 'del', 'dfn', 'dir',
      'div', 'dl', 'dt', 'em', 'fieldset', 'font', 'form', 'h1',
      'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'i', 'img', 'input',
      'ins', 'kbd', 'label', 'legend', 'li', 'map', 'menu',
      'ol', 'optgroup', 'option', 'p', 'pre', 'q', 's', 'samp',
      'select', 'small', 'span', 'strike', 'strong', 'sub',
      'sup', 'table', 'tbody', 'td', 'textarea', 'tfoot', 'th',
      'thead', 'tr', 'tt', 'u', 'ul', 'var'
    ].freeze

    # Default whitelisted attributes.
    ATTRIBUTES = {
      'a'   => ['href'],
      'img' => ['src'],
      :all  => ['abbr', 'accept', 'accept-charset',
                'accesskey', 'action', 'align', 'alt', 'axis',
                'border', 'cellpadding', 'cellspacing', 'char',
                'charoff', 'class', 'charset', 'checked', 'cite',
                'clear', 'cols', 'colspan', 'color',
                'compact', 'coords', 'datetime', 'dir',
                'disabled', 'enctype', 'for', 'frame',
                'headers', 'height', 'hreflang',
                'hspace', 'ismap', 'label', 'lang',
                'longdesc', 'maxlength', 'media', 'method',
                'multiple', 'name', 'nohref', 'noshade',
                'nowrap', 'prompt', 'readonly', 'rel', 'rev',
                'rows', 'rowspan', 'rules', 'scope',
                'selected', 'shape', 'size', 'span',
                'start', 'summary', 'tabindex', 'target',
                'title', 'type', 'usemap', 'valign', 'value',
                'vspace', 'width']
    }.freeze

    # Default whitelisted protocols for URLs.
    PROTOCOLS = {
      'a'   => {'href' => ['http', 'https', 'mailto', :relative]},
      'img' => {'src'  => ['http', 'https', :relative]}
    }.freeze

    # Gets an Array of whitelisted HTML elements.  Default: ELEMENTS.
    attr_reader :elements

    # Gets a Hash describing which attributes are allowed in which HTML
    # elements.  Default: ATTRIBUTES.
    attr_reader :attributes

    # Gets a Hash describing which URI protocols are allowed in HTML 
    # attributes.  Default: PROTOCOLS
    attr_reader :protocols

    # Gets a Hash describing HTML attributes that Sanitize should add.  
    # Default: {}
    attr_reader :add_attributes

    # Sets a boolean determining whether Sanitize allows HTML comments in the
    # output.  Default: false.
    attr_writer :allow_comments

    def initialize
      @elements       = ELEMENTS
      @attributes     = ATTRIBUTES
      @protocols      = PROTOCOLS
      @add_attributes = {}
      @allow_comments = false
      yield self if block_given?
    end

    # Determines if Sanitize should allow HTML comments.
    #
    # Returns True if comments are allowed, or False.
    def allow_comments?
      !!@allow_comments
    end

    # Modifies the current Sanitization instance to sanitize older revisions
    # of pages.
    #
    # Returns a Sanitization instance.
    def history_sanitization
      self.class.new do |sanitize|
        sanitize.add_attributes['a'] = {'rel' => 'nofollow'}
      end
    end

    # Builds a Hash of options suitable for Sanitize.clean.
    #
    # Returns a Hash.
    def to_hash
      { :elements       => elements,
        :attributes     => attributes,
        :protocols      => protocols,
        :add_attributes => add_attributes,
        :allow_comments => allow_comments?
      }
    end

    # Builds a Sanitize instance from the current options.
    #
    # Returns a Sanitize instance.
    def to_sanitize
      Sanitize.new(to_hash)
    end
  end
end

