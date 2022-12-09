module Precious
  module HasMath
    def mathjax
      @math == :mathjax
    end

    def katex
      @math == :katex
    end

    def math_config
      @math_config ? page_route(@math_config) : false
    end
  end
end