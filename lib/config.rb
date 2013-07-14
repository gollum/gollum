module RJGit

  class Configuration
    
    attr_reader :jconfig, :path
    
    def initialize(path)
      @path = path
      @jconfig = org.eclipse.jgit.lib.Config.new
    end
    
    def load
      return self if @loaded
      begin
        @jconfig.from_text(IO.read(@path))
        @loaded = true
      rescue => exception
        @loaded = false
        raise IOException.new(exception.message)
      end
      return self
    end
    
    def [](key)
      section, subsection = key.split
      build_settings_hash(section, subsection)
    end
    
    def build_settings_hash(section, subsection)
      names = names(section, subsection)
      settings = {}
      names.each do |name|
        value = @jconfig.get_string(section, subsection, name)
        if is_num?(value)
          value = value.to_i 
        elsif is_bool?(value)
          value = to_boolean(value)
        end
        settings[name] = value
      end
      settings
    end
    
    def is_num?(str)
      begin
        !!Integer(str)
      rescue ArgumentError, TypeError
        false
      end
    end
    
    def is_bool?(str)
      str = str.strip
      str == 'true' || str == 'false'
    end
    
    def to_boolean(str)
      str == "true"
    end
    
    def loaded?
      @loaded
    end
    
    def sections
      @jconfig.get_sections.to_array
    end
    
    def subsections(section)
      @jconfig.get_subsections(section).to_array
    end
    
    def to_s
      @jconfig.to_text
    end
    
    def add_setting(name, value, section, subsection = "")
      case value
        when Integer then @jconfig.set_int(section, subsection, name, value)
        when TrueClass then @jconfig.set_boolean(section, subsection, name, value)
        when FalseClass then @jconfig.set_boolean(section, subsection, name, value)
        when String then @jconfig.set_string(section, subsection, name, value)
        else nil
      end
    end
    
    def names(section, subsection)
      @jconfig.get_names(section, subsection).to_array
    end
    
  end # Config
end
