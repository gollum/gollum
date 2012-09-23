module RJGit #From Grit gem

  class Config
    def initialize(repo)
      @repo = repo
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

      def load_config
        hash = {}
        config_lines.map do |line|
          key, value = line.split(/=/, 2)
          hash[key] = value
        end
        hash
      end

      def config_lines
        @repo.git.config(:list => true).split(/\n/)
      end
  
  end 
end