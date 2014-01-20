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

  def self.get_file_mode_with_path(jrepo, path, jtree)
    treewalk = TreeWalk.forPath(jrepo, path, jtree)
    return treewalk.get_file_mode(0).get_bits
  end
  
  def self.get_file_mode(jrepo, jblob, revstring=Constants::HEAD)
    last_commit_hash = jrepo.resolve(revstring)
    return nil if last_commit_hash.nil?
    walk = RevWalk.new(jrepo)
    jcommit = walk.parse_commit(last_commit_hash)
    treewalk = TreeWalk.new(jrepo)
    jtree = jcommit.get_tree
    treewalk.add_tree(jtree)
    treewalk.set_recursive(true)
    while treewalk.next
      jblob_lookup = walk.lookup_blob(treewalk.objectId(0))
      if jblob_lookup.get_name == jblob.get_name
        mode = treewalk.get_file_mode(0).get_bits
        return mode
      end
    end
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
      RJGit.diff_entry_to_hash(diff_entry[0], diff_entry[1])
    end
  end
  
  def self.diff_entry_to_hash(diff_entry, patch)
    entry = {}
    entry[:changetype] = diff_entry.get_change_type.to_string
    entry[:oldpath] = diff_entry.get_old_path
    entry[:newpath] = diff_entry.get_new_path
    entry[:oldmode] = diff_entry.get_old_mode.get_bits
    entry[:newmode] = diff_entry.get_new_mode.get_bits
    entry[:score] = diff_entry.get_score
    entry[:oldid] = diff_entry.get_old_id.name
    entry[:newid] = diff_entry.get_new_id.name
    entry[:patch] = patch unless patch == nil
    entry
  end
  
  def self.sym_for_type(type)
    result = case type
    when Constants::OBJ_BLOB
      :blob
    when Constants::OBJ_TREE
      :tree
    when Constants::OBJ_COMMIT
      :commit
    when Constants::OBJ_TAG
      :tag
    end 
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
      when org.eclipse.jgit.lib.ObjectId then tree
      else nil
    end
  end
  
  def self.blob_type(blob)
    blobobj = case blob
      when Blob then blob.jblob
      when org.eclipse.jgit.revwalk.RevBlob then blob
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