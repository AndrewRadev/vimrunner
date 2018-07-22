require File.expand_path('../lib/vimrunner/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'vimrunner'
  s.version     = Vimrunner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andrew Radev', 'Paul Mucur']
  s.email       = ['andrey.radev@gmail.com']
  s.homepage    = 'http://github.com/AndrewRadev/vimrunner'
  s.summary     = 'Lets you control a Vim instance through Ruby'
  s.description = <<-D
    Using Vim's client/server functionality, this library exposes a way to
    spawn a Vim instance and control it programatically. Apart from being a fun
    party trick, this can be used to integration test Vim script.
  D

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rspec', '~> 3.7'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'vimrunner'
  s.files                     = Dir['lib/**/*.rb', 'vim/*', 'bin/*', 'LICENSE', '*.md']
  s.require_path              = 'lib'
  s.executables               = ['vimrunner']
end
