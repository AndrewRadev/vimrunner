require 'fileutils'

ROOT_DIR = File.expand_path('../..', __FILE__)

RSpec.configure do |config|
  config.before :each do
    FileUtils.cd ROOT_DIR
    FileUtils.rm_rf 'tmp' if File.exists? 'tmp'
    FileUtils.mkdir 'tmp'
    FileUtils.cd 'tmp'
  end

  config.after :each do
    FileUtils.cd ROOT_DIR
  end
end
