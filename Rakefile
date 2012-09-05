require 'rubygems'
 
task :default => :rspec

desc "Build the gem file."
task :build do
  system "gem build rjgit.gemspec"
end

require 'rspec/core/rake_task'

desc "Run specs."
RSpec::Core::RakeTask.new(:rspec) do |spec|
  ruby_opts = "-w"
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace --color']
end