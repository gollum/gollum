module Precious
  module Views
    module TemplateCascade
      def template_priority_path
        @@template_priority_path
      end

      def template_priority_path=(path)
        @@template_priority_path = File.expand_path(path)
        @template = nil
      end

      def first_path_available(name)
        priority = "#{template_priority_path}/#{name}.#{template_extension}"
        default = "#{template_path}/#{name}.#{template_extension}"
puts exist: File.exists?(priority), priority: priority, default: default
        File.exists?(priority) ? priority : default
      end

      # Following methods should track lib/mustache/settings.rb from Mustache project.
      def template_file
        @template_file || first_path_available(template_name)
      end

      def partial(name)
        path = first_path_available(name)
        begin
          File.read(path)
        rescue
          raise if raise_on_context_miss?
          ""
        end
      end
    end
  end
end
