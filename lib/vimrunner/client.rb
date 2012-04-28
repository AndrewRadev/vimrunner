require 'vimrunner/shell'
require 'vimrunner/vim'

module Vimrunner

  # A Client is simply a proxy to a Vim server. It's initialized with a Server
  # instance and sends commands, keys and signals to it.
  class Client
    attr_reader :server

    def initialize(server)
      @server = server
    end

    # Adds a plugin to Vim's runtime. Initially, Vim is started without
    # sourcing any plugins to ensure a clean state. This method can be used to
    # populate the instance's environment.
    #
    # dir          - The base directory of the plugin, the one that contains
    #                its autoload, plugin, ftplugin, etc. directories.
    # entry_script - The Vim script that's runtime'd to initialize the plugin.
    #                Optional.
    #
    # Example:
    #
    #   vim.add_plugin 'rails', 'plugin/rails.vim'
    #
    def add_plugin(dir, entry_script = nil)
      command("set runtimepath+=#{dir}")
      command("runtime #{entry_script}") if entry_script
    end

    # Invokes one of the basic actions the Vim server supports, sending a key
    # sequence. The keys are sent as-is, so it'd probably be better to use the
    # wrapper methods, #normal, #insert and so on.
    def type(keys)
      invoke_vim '--remote-send', keys
    end

    # Executes the given command in the Vim instance and returns its output,
    # stripping all surrounding whitespace.
    def command(vim_command)
      normal

      escaped_command = vim_command.to_s.gsub("'", "''")
      expression = "VimrunnerEvaluateCommandOutput('#{escaped_command}')"

      invoke_vim('--remote-expr', expression).strip.tap do |output|
        raise InvalidCommandError if output =~ /^Vim:E\d+:/
      end
    end

    # Starts a search in Vim for the given text. The result is that the cursor
    # is positioned on its first occurrence.
    def search(text)
      normal
      type "/#{text}<cr>"
    end

    # Sets a setting in Vim. If +value+ is nil, the setting is considered to be
    # a boolean.
    #
    # Examples:
    #
    #   vim.set 'expandtab'  # invokes ":set expandtab"
    #   vim.set 'tabstop', 3 # invokes ":set tabstop=3"
    #
    def set(setting, value = nil)
      if value
        command "set #{setting}=#{value}"
      else
        command "set #{setting}"
      end
    end

    # Edits the file +filename+ with Vim.
    #
    # Note that this doesn't use the '--remote' Vim flag, it simply types in
    # the command manually. This is necessary to avoid the Vim instance getting
    # focus.
    def edit(filename)
      command "edit #{filename}"
    end

    # Writes the file being edited to disk. Note that you probably want to set
    # the file's name first by using Runner#edit.
    def write
      command :write
    end

    # Echo each expression with a space in between.
    def echo(*expressions)
      command "echo #{expressions.join(' ')}"
    end

    # Switches Vim to insert mode and types in the given text.
    def insert(text = '')
      normal "i#{text}"
    end

    # Switches Vim to normal mode and types in the given keys.
    def normal(keys = '')
      type "<c-\\><c-n>#{keys}"
    end

    # Kills the server it's connected to.
    def kill
      server.kill
    end

    private

    def invoke_vim(*args)
      Shell.run(Vim.client.executable, '--servername', server.name, *args)
    end
  end
end
