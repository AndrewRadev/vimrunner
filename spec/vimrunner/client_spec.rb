require "spec_helper"
require "vimrunner"

module Vimrunner
  RSpec.describe Client do
    let!(:client) { Vimrunner.start }

    after :each do
      client.kill
    end

    it "is instantiated in the current directory" do
      cwd = FileUtils.getwd
      expect(client.command(:pwd)).to eq(cwd)
    end

    it "can write a file through Vim" do
      client.edit 'some_file'
      client.insert 'Contents of the file'
      client.write

      expect(File.exists?('some_file')).to be(true)
      expect(File.read('some_file').strip).to eq('Contents of the file')
    end

    it "properly escapes filenames" do
      client.edit 'some file'
      client.write

      expect(File.exists?('some file')).to be(true)
    end

    it "can execute commands with a bang" do
      client.edit 'some_file'
      client.insert 'Contents of the file'
      client.edit! 'some_other_file'
      client.insert 'Contents of the other file'
      client.command :write

      expect(File.exists?('some_file')).to be(false)
      expect(File.exists?('some_other_file')).to be(true)
      expect(File.read('some_other_file').strip).to eq('Contents of the other file')
    end

    it "can add a plugin for Vim to use" do
      write_file 'example/plugin/test.vim', 'command Okay echo "OK"'
      client.add_plugin('example', 'plugin/test.vim')

      expect(client.command('Okay')).to eq('OK')
    end

    it "can append a directory to Vim's runtimepath" do
      write_file 'example/test.vim', 'echo "OK"'
      client.append_runtimepath('example')

      expect(client.command('runtime test.vim')).to eq('OK')
    end

    it "can prepend a directory to Vim's runtimepath, giving it priority" do
      write_file 'example_first/test.vim', 'echo "first"'
      write_file 'example_second/test.vim', 'echo "second"'
      client.append_runtimepath('example_first')
      client.prepend_runtimepath('example_second')

      expect(client.command('runtime test.vim')).to eq('second')
    end

    it "can chain several operations" do
      client.edit('some_file').insert('Contents').write
      expect(File.exists?('some_file')).to be(true)
      expect(File.read('some_file').strip).to eq('Contents')
    end

    describe "#set" do
      it "activates a boolean setting" do
        client.set 'expandtab'
        expect(client.command('echo &expandtab')).to eq('1')

        client.set 'noexpandtab'
        expect(client.command('echo &expandtab')).to eq('0')
      end

      it "sets a setting to a given value" do
        client.set 'tabstop', 3
        expect(client.command('echo &tabstop')).to eq('3')
      end

      it "can be chained" do
        client.set('expandtab').set('tabstop', 3)
        expect(client.command('echo &expandtab')).to eq('1')
        expect(client.command('echo &tabstop')).to eq('3')
      end
    end

    describe "#search" do
      before :each do
        client.edit 'some_file'
        client.insert 'one two'
      end

      it "positions the cursor on the search term" do
        client.search 'two'
        client.normal 'dw'

        client.write

        expect(File.read('some_file').strip).to eq('one')
      end

      it "can be chained" do
        client.search('two').search('one')
        client.normal 'dw'

        client.write

        expect(File.read('some_file').strip).to eq('two')
      end
    end

    describe "#echo" do
      it "returns the result of a given expression" do
        expect(client.echo('"foo"')).to eq('foo')
      end

      it "returns the result of multiple expressions" do
        client.command('let b:foo = "bar"')
        expect(client.echo('"foo"', 'b:foo')).to eq('foo bar')
      end
    end

    describe "#feedkeys" do
      before :each do
        client.edit 'some_file'
        client.command 'map <C-R> ihello'
      end

      it "sends keys as if they come from a mapping or user" do
        client.feedkeys('\<C-R>')
        client.write
        expect(File.read('some_file').strip).to eq('hello')
      end

      it "handles quotes" do
        client.feedkeys('\<C-R>\'"')
        client.write
        expect(File.read('some_file').strip).to eq('hello\'"')
      end
    end

    describe "#command" do
      it "returns the output of a Vim command" do
        expect(client.command(:version)).to include('+clientserver')
        expect(client.command('echo "foo"')).to eq('foo')
      end

      it "allows single quotes in the command" do
        expect(client.command("echo 'foo'")).to eq('foo')
      end

      it "raises an error for a non-existent Vim command" do
        expect {
          client.command(:nonexistent)
        }.to raise_error(InvalidCommandError)
      end

      it "maintains whitespace in the output" do
        expect(client.command('echo "  foo  "')).to eq '  foo  '
      end
    end
  end
end
