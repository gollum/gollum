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

  def self.get_file_mode(repository, path, jtree)
    treewalk = TreeWalk.forPath(repository, path, jtree)
    return treewalk.get_file_mode(0).get_bits
  end
  
  def self.stringify(entries)
    str = ""
    entries.each do |entry|
      line = entry.values.join("\t")
      str = "#{str}#{line}\n"
    end
    str
  end
  
  def self.convert_diff_entries(entries)
    entries.map do |diff_entry|
      RJGit. diff_entry_to_hash(diff_entry)
    end
  end
  
  def self.diff_entry_to_hash(diff_entry)
    entry = {}
    entry[:changetype] = diff_entry.get_change_type.to_string
    entry[:oldpath] = diff_entry.get_old_path
    entry[:newpath] = diff_entry.get_new_path
     entry[:oldmode] = diff_entry.get_old_mode.get_bits
     entry[:newmode] = diff_entry.get_new_mode.get_bits
     entry[:score] = diff_entry.get_score
     entry[:oldid] = diff_entry.get_old_id.name
     entry[:newid] = diff_entry.get_new_id.name
     entry
  end
  
  
  def self.repository_type(repository)
    repo = case repository
      when Repo then repository.jrepo
      when org.eclipse.jgit.lib.Repository then repository
      else nil
    end
  end
  
  def self.actor_type(actor)
    person_ident = case actor
      when Actor then actor.person_ident
      when org.eclipse.jgit.lib.PersonIdent then actor
      else nil
    end
  end
  
  def self.tree_type(tree)
    treeobj = case tree
      when Tree then tree.jtree
      when org.eclipse.jgit.revwalk.RevTree then tree
      else nil
    end
  end
  
  def self.commit_type(commit)
    commitobj = case commit
      when Commit then commit.jcommit
      when org.eclipse.jgit.lib.ObjectId then commit
      else nil
    end
  end
    
end