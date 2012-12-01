require 'rubygems'

# -- this is magic line that ensures "../lib" is in the load path -------------
$:.push File.expand_path("../lib", __FILE__)

require "version"

Gem::Specification.new do |s|
  s.name              = "rjgit"
  s.summary           = "JRuby wrapper around the JGit library."
  s.description       = "JRuby wrapper around the JGit library for manipulating git repositories in code."
  s.version           = RJGit::VERSION
  s.authors           = ["Maarten Engelen", "Bart Kamphorst", "Dawa Ometto", "Steven Woudenberg", "Arlette van Wissen"]
  s.email             = "repotag-dev@googlegroups.com"
  s.homepage          = ""
  s.require_paths     = ["lib"]
  s.files             = ["README.md", "Gemfile", "lib/rjgit.rb", "lib/constants.rb", "lib/repo.rb", "lib/version.rb", "lib/git.rb", "lib/commit.rb",
                          "lib/tree.rb", "lib/rjgit_helpers.rb", "lib/blob.rb", "lib/config.rb", "lib/java/jars/org.eclipse.jgit-2.1.0.201209190230-r.jar"]
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('mime-types', "~> 1.15")

end