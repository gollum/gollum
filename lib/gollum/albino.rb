require 'albino/multi'

class Gollum::Albino < Albino::Multi
  self.bin = ::Albino::Multi.bin
end
