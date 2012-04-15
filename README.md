Using Vim's client/server functionality, this library exposes a way to spawn a
Vim instance and control it programatically. Apart from being a fun party
trick, this could be used to do integration testing on vimscript.

This is still fairly experimental, so use with caution. Any issue reports or
contributions are very welcome on the
[github issue tracker](https://github.com/AndrewRadev/Vimrunner/issues)

## Usage

There are two main entry points:

  - `Vimrunner::Runner.start_vim`: Starts a terminal instance. Since it's
    invisible, it's nice for use in automated tests.
  - `Vimrunner::Runner.start_gvim`: Starts a GUI instance of Vim. On Linux,
    it'll be a `gvim`, on Mac it defaults to `mvim`.

Both methods return a `Runner` instance that you can use to command Vim. For a
full list of methods you can call on it, check the instance methods on the
`Runner` class in [the docs](http://rubydoc.info/gems/vimrunner/Vimrunner/Runner).

## Requirements

Vim needs to be compiled with `+clientserver`. This should be available with
the `normal`, `big` and `huge` featuresets. The client/server functionality
(regrettably) needs a running X server to function, even for a terminal vim.
This means that if you're using it for automated tests on a remote server,
you'll probably need to start it with xvfb.

## Settings

If you have a non-standard install, you can specify explicit paths to the Vim
executables like so:

```ruby
Vimrunner::Runner.vim_path  = "/opt/local/bin/vim"
Vimrunner::Runner.gvim_path = "/opt/local/bin/gvim"
```

## Experimenting

The `vimrunner` executable opens up an irb session with `$vim` set to a running
`gvim` instance. You can use this for interactive experimentation. A few things
you can try:

``` ruby
$vim.edit 'some_file_name'  # edit a file
$vim.insert 'Hello, World!' # enter insert mode and write some text
$vim.normal 'T,'            # go back to the nearest comma
$vim.type 'a<cr>'           # append a newline after the comma
$vim.write                  # write file to disk
```
