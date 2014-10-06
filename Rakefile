require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
desc "Generate documentation"
task :doc do
  sh 'rdoc -t "Vimrunner" lib'
end
task :default => :spec
task :pry do
  require 'pry'
  require 'awesome_print'
  ARGV.clear
  Pry.start
end
