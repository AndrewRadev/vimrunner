require 'vimrunner'
require 'vimrunner/testing'

module Vimrunner
  module RSpec
    class Configuration
      attr_accessor :reuse_server

      def start_vim(&block)
        @start_vim_method = block
      end

      def start_vim_method
        @start_vim_method || lambda { Vimrunner.start }
      end
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield configuration
    end
  end

  module Testing
    class << self
      attr_accessor :instance
    end

    def vim
      Testing.instance ||= Vimrunner::RSpec.configuration.start_vim_method.call
    end
  end
end

# Default configuration
Vimrunner::RSpec.configure do |config|
  config.reuse_server = false
end

RSpec.configure do |config|

  # Include the Testing DSL into all examples.
  config.include(Vimrunner::Testing)

  # Each example is executed in a separate directory
  # No trace shall be left in the tmp directory otherwise cygwin won't permit
  # rmdir => vim is outside the directory at the end
  # TODO: ensure a cd(pwd) à la RAII
  pwd = Dir.pwd
  config.around(:each) do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        vim.cd(dir)
        example.run
        vim.cd(pwd)
      end
    end
  end

  config.before(:each) do
    unless Vimrunner::RSpec.configuration.reuse_server
      Vimrunner::Testing.instance.kill if Vimrunner::Testing.instance
      Vimrunner::Testing.instance = nil
    end
  end

  # Kill the Vim server after all tests are over.
  config.after(:suite) do
    Vimrunner::Testing.instance.kill if Vimrunner::Testing.instance
  end
end
