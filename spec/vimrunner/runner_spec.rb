require 'spec_helper'
require 'vimrunner/runner'
require 'vimrunner/errors'

module Vimrunner
  describe Runner do
    let!(:vim) { Runner.start_gvim }

    after :each do
      vim.kill
    end

    it "spawns a vim server" do
      Runner.serverlist.should =~ [vim.servername]
    end

    it "can spawn more than one vim server" do
      begin
        other = Runner.start_gvim
        Runner.serverlist.should =~ [vim.servername, other.servername]
      ensure
        other.kill
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

      File.exists?('some_file').should be_true
      File.read('some_file').strip.should eq 'Contents of the file'
    end

    it "can add a plugin for vim to use" do
      FileUtils.mkdir_p 'example/plugin'
      File.open('example/plugin/test.vim', 'w') do |f|
        f.write 'command Okay echo "OK"'
      end

      vim.add_plugin('example', 'plugin/test.vim')

      vim.command('Okay').should eq 'OK'
    end

    describe "#set" do
      it "activates a boolean setting" do
        vim.set 'expandtab'
        vim.command('echo &expandtab').should eq '1'

        vim.set 'noexpandtab'
        vim.command('echo &expandtab').should eq '0'
      end

      it "sets a setting to a given value" do
        vim.set 'tabstop', 3
        vim.command('echo &tabstop').should eq '3'
      end
    end

    describe "#search" do
      it "positions the cursor on the search term" do
        vim.edit 'some_file'
        vim.insert 'one two'

        vim.search 'two'
        vim.normal 'dw'

        vim.write

        File.read('some_file').strip.should eq 'one'
      end
    end

    describe "#command" do
      it "returns the output of a vim command" do
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
