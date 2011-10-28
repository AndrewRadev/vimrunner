require 'spec_helper'
require 'vimrunner/runner'
require 'vimrunner/errors'

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

    it "is instantiated in the current directory" do
      cwd = FileUtils.getwd
      vim.command(:pwd).should eq cwd
    end

    it "can write a file through vim" do
      vim.edit 'some_file'
      vim.insert 'Contents of the file'
      vim.write
      vim.wait_until_ready

      File.exists?('some_file').should be_true
      File.read('some_file').strip.should eq 'Contents of the file'
    end

    describe "#search" do
      it "positions the cursor on the search term" do
        vim.edit 'some_file'
        vim.insert 'one two'

        vim.search 'two'
        vim.normal 'dw'

        vim.write
        vim.wait_until_ready

        File.read('some_file').strip.should eq 'one'
      end
    end

    describe "#command" do
      it "can return the output of a vim command" do
        vim.command(:version).should include '+clientserver'
        vim.command('echo "foo"').should eq 'foo'
      end

      it "raises an error for a non-existent vim command" do
        expect do
          vim.command(:nonexistent)
        end.to raise_error Vimrunner::InvalidCommandError
      end
    end
  end
end
