# Vimrunner [![Build Status](https://secure.travis-ci.org/AndrewRadev/vimrunner.png?branch=master)](http://travis-ci.org/AndrewRadev/vimrunner)

Using Vim's
[client/server](http://vimdoc.sourceforge.net/htmldoc/remote.html#clientserver)
functionality, this library exposes a way to spawn a Vim instance and control
it programatically. Apart from being a fun party trick, this can be used to do
integration testing on Vimscript.

This is still fairly experimental, so use with caution. Any issue reports or
contributions are very welcome on the
[GitHub issue tracker](https://github.com/AndrewRadev/Vimrunner/issues).

## Usage

Vimrunner can be used in one of two main ways:

```ruby
# Vim will automatically be started and killed.
Vimrunner.start do |vim|
  vim.edit "file.txt"
  vim.insert "Hello"
  vim.write
end
```

```ruby
# Vim will automatically be started but you must manually kill it when you are
# finished.
vim = Vimrunner.start
vim.edit "file.txt"
vim.insert "Hello"
vim.write
vim.kill
```

Vimrunner will attempt to start up the most suitable version of Vim available,
meaning one of the following:

* `vim` if it supports headlessly creating servers (see [Requirements](#requirements) below for more information);
* `mvim` if you are on Mac OS X;
* `gvim`.

If you wish to always start a GUI Vim (viz. skip using a headless `vim`) then
you can use `start_gvim` like so:

```ruby
Vimrunner.start_gvim do |vim|
  # ...
end
```

If you require an even more specific version of Vim, you can pass the path to
it by instantiating your own `Server` instance like so:

```ruby
Vimrunner::Server.new("/path/to/my/specific/vim").start do |vim|
  vim.edit "file.txt"
end
```

(You can also use the non-block form of `start` in both of the above
examples.)

Calling `start` (or `start_gvim`) will return a `Client` instance with which
you can control Vim. For a full list of methods you can invoke on the remote
Vim instance, check out the [`Client`
documentation](http://rubydoc.info/gems/vimrunner/Vimrunner/Client).

## Testing

If you're using Vimrunner for testing vim plugins, take a look at the
documentation for the
[Vimrunner::Testing](http://rubydoc.info/gems/vimrunner/Vimrunner/Testing)
module. It contains a few simple helpers that may make it a bit easier to write
regression tests in rspec. With them, it could work something like this:

``` ruby
require 'spec_helper'
require 'vimrunner/testing'

describe "My Vim plugin" do
  let(:vim) { some_instance_of_vim }

  around :each do |example|
    # needed only once for any Vim instance:
    vim.add_plugin(File.expand_path('../my_plugin_path'), 'plugin/my_plugin.vim')

    # ensure a clean temporary directory for each test:
    Vimrunner::Testing.tmpdir(vim) do
      example.call
    end
  end

  specify "some behaviour" do
    Vimrunner::Testing.write_file('test.rb', <<-EOF)
      def foo
        bar
      end
    EOF

    vim.edit 'test.rb'
    do_plugin_related_stuff_with(vim)
    vim.write

    IO.read('test.rb').should eq Vimrunner::Testing.normalize_string_indent(<<-EOF)
      def bar
        foo
      end
    EOF
  end
end
```

It's possible to make this a lot more concise by including
`Vimrunner::Testing`, by making your own helper methods that wrap common
behaviour, by extracting some code to `spec_helper.rb`, and so on.

## Requirements

Vim needs to be compiled with `+clientserver`. This should be available with
the `normal`, `big` and `huge` featuresets or by using
[MacVim](http://code.google.com/p/macvim/) on Mac OS X. In order to start a
server without a GUI, you will also need `+xterm-clipboard` [as described in
the Vim
manual](http://vimdoc.sourceforge.net/htmldoc/remote.html#x11-clientserver).

The client/server functionality (regrettably) needs a running X server to
function, even without a GUI. This means that if you're using it for
automated tests on a remote server, you'll probably need to start it with
Xvfb.

If you are using MacVim, note that you will need the `mvim` binary in your
`PATH` in order to start and communicate with Vim servers.

## Experimenting

The `vimrunner` executable opens up an irb session with `$vim` set to a running
`gvim` (or `mvim`) client. You can use this for interactive experimentation. A
few things you can try:

``` ruby
$vim.edit 'some_file_name'  # edit a file
$vim.insert 'Hello, World!' # enter insert mode and write some text
$vim.normal 'T,'            # go back to the nearest comma
$vim.type 'a<cr>'           # append a newline after the comma
$vim.write                  # write file to disk
```
