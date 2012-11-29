module RJGit
  
  require 'forwardable'
  extend Forwardable
  
  def self.underscore(camel_cased_word)
    camel_cased_word.to_s.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
  end
  
  def self.delegate_to(klass, delegate_name)
    java_methods = klass.java_class.declared_instance_methods.map{ |method| method.name.to_sym }
    def_delegators delegate_name, *java_methods
  end

  
    
end