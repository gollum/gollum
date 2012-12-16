module RJGit #From Grit gem

  class Config
    
    def initialize(path)
      @path = path
    end

    def []=(key, value)
      @repo.git.config({}, key, value)
      @data = nil
    end

    def [](key)
      data[key]
    end

    def fetch(key, default = nil)
      data[key] || default || raise(IndexError.new("key not found"))
    end
    
    def keys
      data.keys
    end
    alias_method :sections, :keys

    def data
      @data ||= load_config(@path)
    end

    # Use the following for sections:
    # c = '[core]'
    # s = c.delete('[]').to_sym
    # o = "[ #{s} ]"
    def load_config(path)
      hash = {}
      nested_hash = {}
      config_lines(path).map do |line|
        key, value = line.split(/=/, 2)
        key = key.strip unless key.nil?
        value = value.strip unless value.nil?
        if key && value.nil?
          nested_hash = Hash.new
          hash[key] = nested_hash
        elsif key && value
          nested_hash[key] = value
        end
      end
      hash
    end

    def config_lines(path)
      return nil unless File.file?(path)
      IO.readlines(path)
    end
  
  end 
end