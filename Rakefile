require 'rubygems'
 
task :default => :rspec

desc "Build the gem file."
task :build do
  system "gem build rjgit.gemspec"
end

require 'rspec/core/rake_task'

def rename_git_dir
  dot_git = File.join(File.dirname(__FILE__), 'spec', 'fixtures', 'dot_git')
  cp_r File.join(File.dirname(dot_git), '_git'), File.join(dot_git, '.git'), :remove_destination => true
end

desc "Run specs."
RSpec::Core::RakeTask.new(:rspec) do |spec|
  rename_git_dir
  ruby_opts = "-w"
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace --color']
end

