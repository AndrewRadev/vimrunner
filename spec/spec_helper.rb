require "tmpdir"
require "simplecov"

SimpleCov.start

RSpec.configure do |config|
  def write_file(filename, contents)
    dirname = File.dirname(filename)
    FileUtils.mkdir_p dirname if not File.directory?(dirname)

    File.open(filename, 'w') { |f| f.write(contents) }
  end

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
