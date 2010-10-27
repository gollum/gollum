module Gollum

  # Encapsulate sanitization options.
  #
  # This class does not yet support all options of Sanitize library.
  # See http://github.com/rgrove/sanitize/.
  class Sanitization

    #
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
    ]

    #
    ATTRIBUTES = {
      :all => [
        'abbr', 'accept', 'accept-charset',
        'accesskey', 'action', 'align', 'alt', 'axis',
        'border', 'cellpadding', 'cellspacing', 'char',
        'charoff', 'charset', 'checked', 'cite',
        'class', 'clear', 'cols', 'colspan', 'color',
        'compact', 'coords', 'datetime', 'dir',
        'disabled', 'enctype', 'for', 'frame',
        'headers', 'height', 'href', 'hreflang',
        'hspace', 'id', 'ismap', 'label', 'lang',
        'longdesc', 'maxlength', 'media', 'method',
        'multiple', 'name', 'nohref', 'noshade',
        'nowrap', 'prompt', 'readonly', 'rel', 'rev',
        'rows', 'rowspan', 'rules', 'scope',
        'selected', 'shape', 'size', 'span', 'src',
        'start', 'summary', 'tabindex', 'target',
        'title', 'type', 'usemap', 'valign', 'value',
        'vspace', 'width'
      ]
    }

    #
    PROTOCOLS = {
      'a' => {'href' => ['http', 'https', 'mailto', :relative]},
      'img' => {'href' => ['http', 'https', :relative]}
    }

    #
    ADD_ATTRIBUTES = {
      'a' => {'rel' => 'nofollow'}
    }

    # Additional options specifically for histories.
    HISTORY_OPTIONS = {
      :add_attributes => {
        'a' => {'rel' => 'nofollow'}
      }
    }

    #
    def initialize(*settings)
      if settings.empty?
        @elements   = ELEMENTS
        @attributes = ATTRIBUTES
        @protocols  = PROTOCOLS
        @add_attributes = {}
        @allow_comments = false
      else
        @elements   = []
        @attributes = {}
        @protocols  = {}
        @add_attributes = {}
        @allow_comments = false
        settings.each{ |s| merge!(s) }
      end
    end

    def elements
      @elements
    end

    def attributes
      @attributes
    end

    def protocols
      @protocols
    end

    def add_attributes
      @add_attributes
    end

    def allow_comments
      !!@allow_comments
    end

    #
    def to_h
      { :elements       => elements,
        :attributes     => attributes,
        :protocols      => protocols,
        :add_attributes => add_attributes,
        :allow_comments => allow_comments
      }
    end

    #
    def merge(settings)
      self.class.new(self, settings)
    end

    #
    def merge!(settings)
      case settings
      when Sanitization
        other_elements       = settings.elements
        other_attributes     = settings.attributes
        other_protocols      = settings.protocols
        other_add_attributes = settings.add_attributes
      else
        other_elements       = settings[:elements]       || []
        other_attributes     = settings[:attributes]     || {}
        other_protocols      = settings[:protocols]      || {}
        other_add_attributes = settings[:add_attributes] || {}
      end

      elements.concat(other_elements)
      other_attributes.each do |k,v|
        attributes[k] ||= []
        attributes[k].concat(v)
      end
      other_protocols.each do |k,v|
        protocols[k] ||= {}
        protocols[k].merge!(v)
      end
      other_add_attributes.each do |k,v|
        add_attributes[k] ||= {}
        add_attributes[k].merge!(v)
      end
    end

  end

end

