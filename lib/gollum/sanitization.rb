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
      'a'   => {'href' => ['http', 'https', 'mailto', 'ftp', 'irc', :relative]},
      'img' => {'src'  => ['http', 'https', :relative]}
    }.freeze

    ADD_ATTRIBUTES = lambda do |env, node|
      if add = env[:config][:add_attributes][node.name]
        add.each do |key, value|
          node[key] = value
        end
      end
    end

    # Default transformers to force @id attributes with 'wiki-' prefix
    TRANSFORMERS = [
      lambda do |env|
        node = env[:node]
        return if env[:is_whitelisted] || !node.element?
        prefix = env[:config][:id_prefix]
        found_attrs = %w(id name).select do |key|
          if value = node[key]
            node[key] = value.gsub(/\A(#{prefix})?/, prefix)
          end
        end
        if found_attrs.size > 0
          ADD_ATTRIBUTES.call(env, node)
          {}
        end
      end,
      lambda do |env|
        node = env[:node]
        return unless value = node['href']
        prefix = env[:config][:id_prefix]
        node['href'] = value.gsub(/\A\#(#{prefix})?/, '#'+prefix)
        ADD_ATTRIBUTES.call(env, node)
        {}
      end
    ].freeze

    # Gets an Array of whitelisted HTML elements.  Default: ELEMENTS.
    attr_reader :elements

    # Gets a Hash describing which attributes are allowed in which HTML
    # elements.  Default: ATTRIBUTES.
    attr_reader :attributes

    # Gets a Hash describing which URI protocols are allowed in HTML
    # attributes.  Default: PROTOCOLS
    attr_reader :protocols

    # Gets a Hash describing which URI protocols are allowed in HTML
    # attributes.  Default: TRANSFORMERS
    attr_reader :transformers

    # Gets or sets a String prefix which is added to ID attributes.
    # Default: 'wiki-'
    attr_accessor :id_prefix

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
      @transformers   = TRANSFORMERS
      @add_attributes = {}
      @allow_comments = false
      @id_prefix      = 'wiki-'
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
        :allow_comments => allow_comments?,
        :transformers   => transformers,
        :id_prefix      => id_prefix
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

