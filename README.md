# Vimrunner [![Build Status](https://secure.travis-ci.org/AndrewRadev/vimrunner.png?branch=master)](http://travis-ci.org/AndrewRadev/vimrunner)

Using Vim's
[client/server](http://vimdoc.sourceforge.net/htmldoc/remote.html#clientserver)
functionality, this library exposes a way to spawn a Vim instance and control
it programatically. Apart from being a fun party trick, this can be used to
integration test Vim script.

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
meaning:

* `vim` if it supports headlessly creating servers;
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
vim instance, check out the [`Client`
documentation](http://rubydoc.info/gems/vimrunner/Vimrunner/Client).

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
xvfb.

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
