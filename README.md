# Vimrunner [![Build Status](https://secure.travis-ci.org/AndrewRadev/vimrunner.svg?branch=master)](http://travis-ci.org/AndrewRadev/vimrunner)

Using Vim's
[client/server](http://vimdoc.sourceforge.net/htmldoc/remote.html#clientserver)
functionality, this library exposes a way to spawn a Vim instance and control
it programatically. Apart from being a fun party trick, this can be used to do
integration testing on Vimscript.

![Demo](http://i.andrewradev.com/cb035fee68a149c09c3a252fed91b177.gif)

The latest stable documentation can be found
[on rubydoc.info](http://rubydoc.info/gems/vimrunner/frames).

Any issue reports or contributions are very welcome on the
[GitHub issue tracker](https://github.com/AndrewRadev/Vimrunner/issues).

## Usage

If you don't already have a running Vim server, Vimrunner can be used in one
of two main ways:

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
Vimrunner::Server.new(:executable => "/path/to/my/specific/vim").start do |vim|
  vim.edit "file.txt"
end
```

(You can also use the non-block form of `start` in both of the above
examples.)

Calling `start` (or `start_gvim`) will return a `Client` instance with which
you can control Vim. For a full list of methods you can invoke on the remote
Vim instance, check out the `Client`
[documentation](http://rubydoc.info/gems/vimrunner/Vimrunner/Client).

If you already have a remote-capable Vim server running, you can connect
Vimrunner to it directly by using `Vimrunner.connect` or `Vimrunner.connect!`
like so:

```ruby
# Assuming a running Vim server called FOO...
vim = Vimrunner.connect("FOO")
if vim
  vim.insert("Hello world!")
end

# Or, if you're confident there's a running server...
vim = Vimrunner.connect!("FOO")
vim.insert("Hello world!")
```

In case of failure to find the server `FOO`, the first form will return `nil`,
while the second form will raise an exception.

## Testing

If you're using Vimrunner for testing vim plugins, a simple way to get up and
running is by requiring the `vimrunner/rspec` file. With that, your
`spec_helper.rb` would look like this:

``` ruby
require 'vimrunner'
require 'vimrunner/rspec'

Vimrunner::RSpec.configure do |config|
  # Use a single Vim instance for the test suite. Set to false to use an
  # instance per test (slower, but can be easier to manage).
  config.reuse_server = true

  # Decide how to start a Vim instance. In this block, an instance should be
  # spawned and set up with anything project-specific.
  config.start_vim do
    vim = Vimrunner.start

    # Or, start a GUI instance:
    # vim = Vimrunner.start_gvim

    # Setup your plugin in the Vim instance
    plugin_path = File.expand_path('../..', __FILE__)
    vim.add_plugin(plugin_path, 'plugin/my_plugin.vim')

    # The returned value is the Client available in the tests.
    vim
  end
end
```

This will result in:

- A `vim` helper in every rspec example, returning the configured
  `Vimrunner::Client` instance.
- Every example is executed in a separate temporary directory to make it easier
  to manipulate files.
- A few helper methods from the `Vimrunner::Testing` module
  ([documentation](http://rubydoc.info/gems/vimrunner/Vimrunner/Testing)).

The specs would then look something like this:

``` ruby
require 'spec_helper'

describe "My Vim plugin" do
  specify "some behaviour" do
    write_file('test.rb', <<-EOF)
      def foo
        bar
      end
    EOF

    vim.edit 'test.rb'
    do_plugin_related_stuff_with(vim)
    vim.write

    IO.read('test.rb').should eq normalize_string_indent(<<-EOF)
      def bar
        foo
      end
    EOF
  end
end
```

If you need a different setup, please look through the file
`lib/vimrunner/rspec.rb` for ideas on how to build your own testing scaffold.

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
