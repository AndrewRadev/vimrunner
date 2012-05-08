require "tmpdir"
require "simplecov"

SimpleCov.start

RSpec.configure do |config|

  # Execute each example in its own temporary directory that is automatically
  # destroyed after every run.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end
end
