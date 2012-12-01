module RJGit
  
  import 'org.eclipse.jgit.lib.FileMode'
  
  TREE_TYPE = 0040000
  SYMLINK_TYPE = 0120000
  FILE_TYPE = 0100000
  GITLINK_TYPE = 0160000
  MISSING_TYPE = 0000000
  REG_FILE_TYPE = 100644
  
  DEFAULT_MIME_TYPE = "text/plain"
  
end