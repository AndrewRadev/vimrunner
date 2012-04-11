Using Vim's client/server functionality, this library exposes a way to spawn a
Vim instance and control it programatically. Apart from being a fun party
trick, this could be used to do integration testing on vimscript.

The `vimrunner` executable opens up an irb session with `$vim` set to a running
`vim` instance. A few things you can try:

``` ruby
$vim.edit 'some_file_name'  # edit a file
$vim.insert 'Hello, World!' # enter insert mode and write some text
$vim.normal 'T,'            # go back to the nearest comma
$vim.type 'a<cr>'           # append a newline after the comma
$vim.write                  # write file to disk
```

For more examples of what you can do, you could take a look at the specs, they
should be fairly readable.

This should work on a Linux box and a Mac with MacVim and the `mvim` binary
installed (the runner will attempt to select the appropriate `vim` binary for
your platform). If you have a non-standard install, you can specify an explicit
`vim_path` like so:

```ruby
Vimrunner::Runner.vim_path = "/opt/local/bin/gvim"
```

This is still fairly experimental, so use with caution. Any issue reports or
contributions are very welcome on the
[github issue tracker](https://github.com/AndrewRadev/Vimrunner/issues)
