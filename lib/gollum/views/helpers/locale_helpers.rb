module Precious
  module Views
    module LocaleHelpers
      NO_METHOD_MESSAGE = 'Argument must be a view method'
      YAML_VARIABLE_REGEXP = /\%\{[\w]+\}/

      # Returns all I18n translation strings for the current view class.
      # This method support YAML arguments. For example:
      #
      #     last_edited: This content was last edited at %{date}.
      #
      # Where the `date` argument must be a method available on the current
      # class.
      #
      # Use this interface within Mustache templates to render any user
      # interface strings in the current locale. For example:
      #
      #     {{ t.last_edited }}
      #
      def t
        autofill I18n.t(locale_klass_name)
      end

      # Returns all I18n translation strings from the root of an I18n YAML file.
      # Otherwise, it works exactly like the `#t` method that's also defined in
      # this file.
      def tt
        autofill I18n.t('.')
      end

      private

      # Recursively looks up I18n translation values and autofills any YAML
      # arguments with the return value of the current class's matching method.
      #
      # When a translation value with an argument has no matching method, we
      # then return that value transformed to include the `no_method_message`
      #
      def autofill(yaml)
        yaml.map { |i18n_key, i18n_value|
          if i18n_value.is_a? Hash
            [i18n_key, autofill(i18n_value)]
          elsif has_arguments?(i18n_value)
            fill_argument_content(i18n_key, i18n_value)
          else
            [i18n_key, i18n_value]
          end
        }.to_h
      end

      def fill_argument_content(i18n_key, i18n_value)
        i18n_value = i18n_value.gsub(YAML_VARIABLE_REGEXP) do |argument|
          method_name = argument.gsub(/[^\w]/, '')

          next if method_name.nil?

          begin
            self.public_send(method_name)
          rescue NoMethodError => error
            no_method_message(method_name)
          end
        end

        [i18n_key, i18n_value]
      end

      def has_arguments?(i18n_value)
        i18n_value.match?(YAML_VARIABLE_REGEXP)
      end

      # Returns the current class name in a format that is acceptable in YAML.
      # To summarize its function:
      #
      #     NameOfConstant => name_of_constant
      #
      def locale_klass_name
        @locale_klass_name ||= self.class.name.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr('-', '_').
          downcase
      end

      def no_method_message(method_name, message = NO_METHOD_MESSAGE)
        "[#{message}: #{method_name}]"
      end
    end
  end
end
