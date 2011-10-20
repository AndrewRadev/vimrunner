require 'spec_helper'
require 'vimrunner/runner'

module Vimrunner
  describe Runner do
    it "spawns a vim server with the name VIMRUNNER" do
      vim = Runner.new('gvim')

      IO.popen 'vim --serverlist' do |io|
        io.read.strip.should eq 'VIMRUNNER'
      end

      vim.quit
    end

    it "can write a file through vim" do
      vim = Runner.new('gvim')

      vim.edit 'some_file'
      vim.insert
      vim.type 'Contents of the file'
      vim.write

      sleep 0.1

      File.exists?('some_file').should be_true
      File.read('some_file').strip.should eq 'Contents of the file'

      vim.quit
    end
  end
end
