require 'rubygems'

# -- this is magic line that ensures "../lib" is in the load path -------------
$:.push File.expand_path("../lib", __FILE__)

require "version"

Gem::Specification.new do |s|
  s.name              = "rjgit"
  s.summary           = "JRuby wrapper around the JGit library."
  s.description       = "JRuby wrapper around the JGit library for manipulating git repositories in code."
  s.version           = RJGit::VERSION
  s.authors           = ["Bart Kamphorst", "Dawa Ometto", "Maarten Engelen", "Patrick Pepels", "Steven Woudenberg", "Arlette van Wissen"]
  s.email             = "repotag-dev@googlegroups.com"
  s.homepage          = ""
  s.require_paths     = ["lib"]
  s.files             = ["README.md", "Gemfile", "lib/rjgit.rb", "lib/ref.rb", "lib/repo.rb", "lib/version.rb", "lib/git.rb", "lib/commit.rb",
                          "lib/java/jars/org.eclipse.jgit-1.3.0.201202151440-r.jar"]
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]

end