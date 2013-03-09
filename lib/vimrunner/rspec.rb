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

  # This only applies to example groups with :filesystem => true in their
  # metadata meaning that you can easily opt-in.
  #
  # Examples
  #
  #   describe "#write", :filesystem => true do
  #     it "saves to disk" do
  #       vim.edit("foo")
  #       vim.insert("bar")
  #       vim.write
  #
  #       expect(File.read("foo").chomp).to eq("bar")
  #     end
  #   end
  #
  config.around(:each, :filesystem => true) do |example|
    tmpdir(vim) do
      example.run
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
