require 'ostruct'
require 'vimrunner'
require 'vimrunner/testing'

module Vimrunner
  module RSpec
    class << self
      attr_accessor :instance, :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield configuration
      end

      def start
        if not %w(start start_gvim).include?(configuration.start_method.to_s)
          raise "Don't know how to start Vimrunner with '#{configuration.start_method}'"
        end

        client = Vimrunner.public_send(configuration.start_method)

        if configuration.after_start_callback
          configuration.after_start_callback.call(client)
        end

        client
      end

      class Configuration
        attr_accessor :start_method, :reuse_server
        attr_reader :after_start_callback

        def after_start(&block)
          @after_start_callback = block
        end
      end
    end
  end

  module Testing
    def vim
      Vimrunner::RSpec.instance ||= Vimrunner::RSpec.start
    end
  end
end

# Default configuration
Vimrunner::RSpec.configure do |config|
  config.reuse_server = false
  config.start_method = :start_gvim

  config.after_start do |vim|
  end
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
    if not Vimrunner::RSpec.configuration.reuse_server
      Vimrunner::RSpec.instance = nil
    end
  end

  # Kill the Vim server after all tests are over.
  config.after(:suite) do
    Vimrunner::RSpec.instance.kill if Vimrunner::RSpec.instance
  end
end
