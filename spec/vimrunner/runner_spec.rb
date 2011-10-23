require 'spec_helper'
require 'vimrunner/runner'

module Vimrunner
  describe Runner do
    let!(:vim) { Runner.start_gvim }

    after :each do
      vim.kill
    end

    it "spawns a vim server with the name VIMRUNNER" do
      IO.popen 'vim --serverlist' do |io|
        io.read.strip.should eq 'VIMRUNNER'
      end
    end

    it "can return the output of a vim command" do
      vim.command(:version).should include '+clientserver'
      vim.command('echo "foo"').should eq 'foo'
    end

    it "is instantiated in the current directory" do
      cwd = FileUtils.getwd
      vim.command(:pwd).should eq cwd
    end

    it "can write a file through vim" do
      vim.edit 'some_file'
      vim.insert 'Contents of the file'
      vim.write
      vim.sync

      File.exists?('some_file').should be_true
      File.read('some_file').strip.should eq 'Contents of the file'
    end
  end
end
