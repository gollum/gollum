module Precious
  module Editable
    def has_editor
      true
    end

    def default_keybinding
      @default_keybinding
    end

    def keybindings
      Gollum::KEYBINDINGS.map do |kb|
        { :name => kb,
          :selected => default_keybinding == kb
        }
      end
    end

    def formats(selected = @page.format)
      Gollum::Markup.formats.map do |key, val|
        { :name     => val[:name],
          :id       => key.to_s,
          :enabled  => val.fetch(:enabled, true),
          :ext      => Gollum::Page.format_to_ext(key),
          :selected => selected == key }
      end.sort do |a, b|
        a[:name].downcase <=> b[:name].downcase
      end
    end
  end
end
