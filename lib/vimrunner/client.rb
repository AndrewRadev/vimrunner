require 'vimrunner/shell'

module Vimrunner
  class Client
    def initialize(server)
      @server = server
    end

    # Adds a plugin to Vim's runtime. Initially, Vim is started without
    # sourcing any plugins to ensure a clean state. This method can be used to
    # populate the instance's environment.
    #
    # dir          - The base directory of the plugin, the one that contains
    #                its autoload, plugin, ftplugin, etc. directories.
    # entry_script - The vim script that's runtime'd to initialize the plugin.
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

    # Invokes one of the basic actions the vim server supports, sending a key
    # sequence. The keys are sent as-is, so it'd probably be better to use the
    # wrapper methods, #normal, #insert and so on.
    def type(keys)
      invoke_vim '--remote-send', keys
    end

    # Executes the given command in the vim instance and returns its output,
    # stripping all surrounding whitespace.
    def command(vim_command)
      normal

      expression = "VimrunnerEvaluateCommandOutput('#{vim_command.to_s}')"

      invoke_vim('--remote-expr', expression).strip.tap do |output|
        raise InvalidCommandError if output =~ /^Vim:E\d+:/
      end
    end

    # Starts a search in vim for the given text. The result is that the cursor
    # is positioned on its first occurrence.
    def search(text)
      normal
      type "/#{text}<cr>"
    end

    # Sets a setting in vim. If +value+ is nil, the setting is considered to be
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
    # Note that this doesn't use the '--remote' vim flag, it simply types in
    # the command manually. This is necessary to avoid the vim instance getting
    # focus.
    def edit(filename)
      command "edit #{filename}"
    end

    # Writes the file being edited to disk. Note that you probably want to set
    # the file's name first by using Runner#edit.
    def write
      command :write
    end

    # Switches vim to insert mode and types in the given text.
    def insert(text = '')
      normal "i#{text}"
    end

    # Switches vim to normal mode and types in the given keys.
    def normal(keys = '')
      type "<c-\\><c-n>#{keys}"
    end

    def kill
      @server.kill
    end

    private

    def invoke_vim(*args)
      args = [@server.vim_path, '--servername', @server.name, *args]
      Shell.run *args
    end
  end
end
