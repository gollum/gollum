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

  def self.get_file_mode(repository, path, revtree)
    treewalk = TreeWalk.forPath(repository, path, revtree)
    return treewalk.get_file_mode(0).get_bits
  end
  
  def stringify(entries)
    strio = StringIO.new
    entries.each do |entry|
      line = entry.values.join("\t")
      strio.write line
      strio.write "\n"
    end
    strio.string
  end
  
  def repository_type(repository)
    repo = case repository
      when Repo then repository.repo
      when org.eclipse.jgit.lib.Repository then repository
      else nil
    end
  end
  
  def tree_type(tree)
    treeobj = case tree
      when Tree then tree.revtree
      when org.eclipse.jgit.revwalk.RevTree then tree
      else nil
    end
  end
    
end