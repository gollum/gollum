module RJGit

  class Config
    
    attr_reader :path, :settings, :groups
    
    def initialize(path)
      @path = path
      @settings, @groups = [], []
    end
    
    def [](key)
      @groups.find{|group| group.name == key }
    end

    def add_setting(key, value, comment = nil)
      setting = Setting.new(key, value)
      setting.add_comment(comment) if comment
      @settings << setting
    end

    def add_group(name, comment = nil)
      group = Group.new(name)
      group.add_comment(comment) if comment
      @groups << group
    end
    
    def sections
      @groups.map{|group| group.name}
    end

    def all_groups
      @all_groups ||= nil
    end
    
    def load
      return nil if @loaded
      load_config(@path)
    end

    def show(io = $stdout)
      @settings.each do |setting|
        setting.comments.each {|comment| io.puts comment }
        io.puts setting.to_s
      end
      @groups.each do |group|
        group.show(io)
      end
    end
    
    def store(path = @path)
      File.open(path, 'w') do |file|
        self.show(file)
      end
    end
    
    private
    def load_config(path)
      comments = []
      indent_level = 0
      result, current_group = nil, nil
      @all_groups = []
      
      config_lines(path).each do |line|
        if line.match(/^(\#|;)/) then comments << line ; next ; end
        key, value = line.split(/=/, 2)
        whitespace_count = key.match(/^(\s*)/)[0].size
        # No value: either it is a group heading or a non-value setting
        if value.nil?
          if group = key.match(/\[.+\]/)
            group_name = group[0].delete('[]').strip
            result = Group.new(group_name, comments, whitespace_count)
          else
            result = Setting.new(key.strip, true, comments)
          end
        # Otherwise clean key and value
        else
          # Check the value for in-line comment
          if m = value.match(/(\#|;).*$/)
            comments << m.to_s
            value = value.gsub(m.to_s, '')
          end
          # Now strip key and value
          key, value = key.strip, value.strip
          # And instantiate a setting
          result = Setting.new(key, value, comments)
        end
        # Reset comments
        comments = []
        if result.is_a? Group
          if whitespace_count > indent_level # then we have a nested group
            if current_group
              result.parent_id = current_group.id
              result.indent_level = current_group.indent_level + 1
              current_group.groups << result
            else
              @groups << result
            end
          elsif whitespace_count < indent_level # moving back up the tree
            # Determine the parent group based on indentation
            current_group = Group.find_parent_group(@all_groups, whitespace_count)
            # Recalibrate the result's indent_level based on the parent
            result.indent_level = current_group ? current_group.indent_level + 1 : 0
            # Add the result to the proper groups array
            current_group ? current_group.groups << result : @groups << result
          elsif current_group
            # Otherwise add result to the current_group's parent
            current_group.parent_id ? Group.find_group_by_id(@all_groups, current_group.parent_id).groups << result : @groups << result
          else
            # Or if there is no parent, to the top level groups array
            @groups << result
          end
          @all_groups << result
          current_group = result
          indent_level = whitespace_count
        elsif result.is_a? Setting
          current_group ? current_group.settings << result : @settings << result
        end
      end
      @loaded = true
      return self
    end

    def config_lines(path)
      return [] unless File.file?(path)
      IO.readlines(path)
    end
      
    class Setting
      attr_accessor :key, :value, :comments
      
      def initialize(key, value, comments = [])
        @key = key
        @value = value
        @comments = comments
      end
      
      def add_comment(comment)
        comment = "# " + comment unless comment.match(/^(\#|;)/)
        @comments << comment
      end
      
      def to_s
        "#{key} = #{value}"
      end
    end # Setting
    
    class Group
      attr_accessor :id, :parent_id, :name, :settings, :groups, :comments, :indent_level
      
      def initialize(name, comments = [], indent_level = 0)
        @id = generate_id
        @name = name
        @settings, @groups = [], []
        @comments = comments
        @indent_level = indent_level
      end 
      
      def [](key)
        @settings.find{ |setting| setting.key == key }
      end
      
      def fetch(key, default = nil)
        self[key] || default || raise(IndexError.new)
      end
      
       def group(name)
          Group.find_group_by_name(@groups, name)
        end
      
      def add_comment(comment)
        comment = "# " + comment unless comment.match(/^(\#|;)/)
        @comments << comment
      end
      
      def add_setting(key, value, comment = nil)
        setting = Setting.new(key, value)
        setting.add_comment(comment) if comment
        @settings << setting
      end
      
      def self.find_group_by_name(groups, name)
        groups.find { |group| group.name == name }
      end
      
      def self.find_group_by_indentation(groups, count)
        group = nil
        group = groups.find { |group| group.indent_level == count }
        if group.nil?
          group = groups.find_all{|group| group.indent_level < count}.sort_by{|g| g.indent_level}.reverse.first
        end
        group
      end
      
      def self.find_parent_group(groups, count)
        group = Group.find_group_by_indentation(groups, count)
        return nil unless group
        Group.find_group_by_id(groups, group.parent_id)
      end
      
      def self.find_group_by_id(groups, id)
        group = groups.find { |group| group.id == id }
      end
      
      def to_s
        "[ #{@name} ]"
      end
      
      def show(io = $stdout)
        @comments.each {|comment| io.puts comment }
        tabs = "\t" * @indent_level 
        io.puts tabs + self.to_s
        @settings.each do |setting|
          setting.comments.each {|comment| io.puts tabs + "\t" + comment }
          io.puts tabs + "\t" + setting.to_s
        end
        @groups.each do |group|
          group.show(io)
        end
      end
      
      private
      def generate_id
        (0...10).map{ ('a'..'z').to_a[rand(26)] }.join + (0...10).map{ rand(9) }.join
      end
      
    end # Group
    
  end # Config
end