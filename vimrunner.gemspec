require File.expand_path('../lib/vimrunner/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'vimrunner'
  s.version     = Vimrunner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Andrew Radev']
  s.email       = ['andrey.radev@gmail.com']
  s.homepage    = 'http://github.com/AndrewRadev/vimrunner'
  s.summary     = 'Lets you control a vim instance through ruby'
  s.description = <<-D
    Using vim's client/server functionality, this library exposes a way to
    spawn a vim instance and control it programatically. Apart from being a fun
    party trick, this could be used to do integration testing on vimscript.
  D

  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rspec', '>= 2.0.0'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'vimrunner'
  s.files                     = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  s.require_path              = 'lib'
  s.executables               = ['vimrunner']
end
