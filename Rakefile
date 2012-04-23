require 'bundler'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks
RSpec::Core::RakeTask.new(:spec)

desc "Generate documentation"
task :doc do
  sh 'rdoc -t "Vimrunner" lib'
end

task :default => :spec
