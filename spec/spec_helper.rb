require 'tmpdir'

RSpec.configure do |config|

  # Create a temporary directory for every test.
  config.around do |example|
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        example.call
      end
    end
  end
end
