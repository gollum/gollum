require 'rubygems'

# -- this is magic line that ensures "../lib" is in the load path -------------
$:.push File.expand_path("../lib", __FILE__)

require "version"

Gem::Specification.new do |s|
  s.name              = "rjgit"
  s.summary           = "JRuby wrapper around the JGit library."
  s.description       = "JRuby wrapper around the JGit library for manipulating git repositories in code."
  s.version           = RJGit::VERSION
  s.authors           = ["Maarten Engelen", "Bart Kamphorst", "Dawa Ometto", "Arlette van Wissen", "Steven Woudenberg"]
  s.email             = "repotag-dev@googlegroups.com"
  s.homepage          = "https://github.com/repotag/rjgit"
  s.require_paths     = ["lib"]
  s.files             = Dir['lib/**/*.rb'] + ["README.md", "LICENSE", "Gemfile"] + Dir['lib/java/jars/*.jar']
  s.has_rdoc          = true
  s.extra_rdoc_files  = ["README.md"]
  s.licenses          = ['Modified BSD', 'EPL']
  s.rdoc_options = ["--charset=UTF-8"]

  s.add_dependency('mime-types', "~> 1.15")

end