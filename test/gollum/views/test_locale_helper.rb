require_relative "../../helper"
require_relative "../../../lib/gollum/views/helpers"

describe Precious::Views::LocaleHelpers do
  class TestClass < Mustache
    include Precious::Views::LocaleHelpers

    def author
      "J.R.R."
    end

    def location
      "Bloemfontein"
    end
  end

  def setup
    I18n.available_locales = [:en, :de]
    I18n.load_path = Dir[File.expand_path("test/support/locales" + "/*.yml")]
  end

  def teardown
    I18n.locale = :en
    I18n.load_path = Dir[::File.expand_path("lib/gollum/locales") + "/*.yml"]
  end

  let(:dummy_instance) { TestClass.new }

  describe "#t" do
    describe "mustache usage" do
      let(:subject) { dummy_instance.render(mustache_template) }

      let(:mustache_template) { "{{ t.hello_world }}" }

      describe "in the default locale" do
        it "returns the translation string" do
          _(subject).must_equal "Hello world"
        end
      end

      describe "in the configured locale" do
        it "returns the translation string" do
          I18n.locale = :de

          _(subject).must_equal "Hallo Welt"
        end
      end

      describe "translations with YAML arguments" do
        let(:mustache_template) { "{{ t.author_info.full }}" }

        describe "in the default locale" do
          it "autofills YAML arguments" do
            _(subject).must_equal "Author J.R.R. is from Bloemfontein"
          end
        end

        describe "in the configured locale" do
          it "autofills YAML arguments" do
            I18n.locale = :de

            _(subject).must_equal "Autor J.R.R. ist vom Bloemfontein"
          end
        end
      end

      describe "translations with invalid arguments" do
        let(:mustache_template) { "{{ t.has_invalid_argument }}" }

        it "fails gracefully with embedded error message" do
          expected_string = "Welcome to " \
            "[#{TestClass::NO_METHOD_MESSAGE}: no_matching_method]"

          _(subject).must_equal expected_string
        end
      end

      describe "out of scope translations" do
        let(:mustache_template) { "{{ t.never_called }}" }

        it "does not include translation keys from other classes" do
          _(subject).must_be_empty
        end
      end

      describe "missing translations" do
        let(:mustache_template) { "{{ t.nested.nonexistent_key }}" }

        it "outputs an empty string" do
          _(subject).must_be_empty
        end
      end
    end

    describe "usage" do
      let(:subject) { dummy_instance.t }

      it "returns a hash" do
        _(subject).must_be_kind_of Hash
      end

      it "returns translation keys under 'test_class'" do
        i18n_keys = I18n.t("test_class").keys

        _(subject.keys).must_equal i18n_keys
      end

      it "does not return translation keys under other classes" do
        other_i18n_keys = I18n.t("nonexistent_test_class").keys

        _(subject.keys).wont_include other_i18n_keys
      end

      it "returns nested keys" do
        nested_keys = subject[:author_info].keys

        _(nested_keys).must_equal [:full]
      end

      describe "auto-filled YAML arguments" do
        let(:subject) { dummy_instance.t[:author_info][:full] }

        it "auto-fills in the default locale" do
          _(subject).must_equal "Author J.R.R. is from Bloemfontein"
        end

        it "auto-fills in a configured locale" do
          I18n.locale = :de

          _(subject).must_equal "Autor J.R.R. ist vom Bloemfontein"
        end
      end
    end
  end

  describe "#tt" do
    describe "mustache usage" do
      let(:subject) { dummy_instance.render(mustache_template) }

      let(:mustache_template) { "{{ tt.test_class.hello_world }}" }

      describe "in the default locale" do
        it "returns the translation string" do
          _(subject).must_equal "Hello world"
        end
      end

      describe "in the configured locale" do
        it "returns the translation string" do
          I18n.locale = :de

          _(subject).must_equal "Hallo Welt"
        end
      end

      describe "translations with YAML arguments" do
        let(:mustache_template) { "{{ tt.test_class.author_info.full }}" }

        describe "in the default locale" do
          it "autofills YAML arguments" do
            _(subject).must_equal "Author J.R.R. is from Bloemfontein"
          end
        end

        describe "in the configured locale" do
          it "autofills YAML arguments" do
            I18n.locale = :de

            _(subject).must_equal "Autor J.R.R. ist vom Bloemfontein"
          end
        end
      end

      describe "translations with invalid arguments" do
        let(:mustache_template) { "{{ tt.test_class.has_invalid_argument }}" }

        it "fails gracefully with embedded error message" do
          expected_string = "Welcome to " \
            "[#{TestClass::NO_METHOD_MESSAGE}: no_matching_method]"

          _(subject).must_equal expected_string
        end
      end

      describe "missing translations" do
        let(:mustache_template) {
          "{{ tt.test_class.nested.nonexistent_key }}"
        }

        it "outputs an empty string" do
          _(subject).must_be_empty
        end
      end
    end

    describe "usage" do
      let(:subject) { dummy_instance.tt }

      it "returns a hash" do
        _(subject).must_be_kind_of Hash
      end

      it "returns all present translation keys" do
        i18n_keys = I18n.t(".").keys

        _(subject.keys).must_equal i18n_keys
      end

      it "returns nested keys" do
        nested_keys = subject[:test_class][:author_info].keys

        _(nested_keys).must_equal [:full]
      end

      describe "auto-filled YAML arguments" do
        let(:subject) { dummy_instance.tt[:test_class][:author_info][:full] }

        it "auto-fills in the default locale" do
          _(subject).must_equal "Author J.R.R. is from Bloemfontein"
        end

        it "auto-fills in a configured locale" do
          I18n.locale = :de

          _(subject).must_equal "Autor J.R.R. ist vom Bloemfontein"
        end
      end
    end
  end
end
