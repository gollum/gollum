# ~*~ encoding: utf-8 ~*~

module Grit
  class Blob
    def is_symlink
      self.mode == 0120000
    end

    def symlink_target(base_path = nil)
      target = self.data
      new_path = File.expand_path(File.join('..', target), base_path)

      if File.file? new_path
        return new_path
      end
    end

    nil
  end
end
