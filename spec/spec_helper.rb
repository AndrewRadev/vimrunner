require 'tmpdir'

RSpec.configure do |config|
  config.before :each do
    @tmpdir = Dir.mktmpdir
    Dir.chdir(@tmpdir)
  end

  config.after :each do
    FileUtils.remove_entry_secure @tmpdir
  end
end
