module RJGit #From Grit gem

  class Config
    
    def initialize
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

    protected
      def data
        @data ||= load_config
      end

      def load_config(config_path)
        hash = {}
        config_lines.map do |line|
          key, value = line.split(/=/, 2)
          hash[key] = value
        end
        hash
      end

      def config_lines(config_path)
        return nil unless File.file?(config_path)
        IO.readlines(config_path)
      end
  
  end 
end