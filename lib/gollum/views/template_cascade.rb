module Precious
  module Views
    module TemplateCascade
      def template_priority_path
        @@template_priority_path ||= nil
      end

      def template_priority_path=(path)
        @@template_priority_path = File.expand_path(path)
        @template = nil
      end

      def first_path_available(name)
        default = File.join(template_path, "#{name}.#{template_extension}")
        priority =
          if template_priority_path
            File.join(template_priority_path, "#{name}.#{template_extension}")
          end

        priority && File.exist?(priority) ? priority : default
      end

      # Method should track lib/mustache/settings.rb from Mustache project.
      def template_file
        @template_file || first_path_available(template_name)
      end
    end
  end
end
