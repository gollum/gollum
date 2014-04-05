module Precious
  module Editable
    def formats(selected = @page.format)
      Gollum::Markup.formats.map do |key, val|
        { :name     => val[:name],
          :id       => key.to_s,
          :selected => selected == key }
      end.sort do |a, b|
        a[:name].downcase <=> b[:name].downcase
      end
    end
  end
end
