module Precious
  module HasMath
    def mathjax
      @math == :mathjax
    end

    def katex
      @math == :katex
    end
  end
end