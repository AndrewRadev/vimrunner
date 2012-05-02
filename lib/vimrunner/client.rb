module Vimrunner
  class Client
    attr_reader :server

    def initialize(server)
      @server = server
    end

    # Public: Adds a plugin to Vim's runtime. Initially, Vim is started
    # without sourcing any plugins to ensure a clean state. This method can be
    # used to populate the instance's environment.
    #
    # dir          - The base directory of the plugin, the one that contains
    #                its autoload, plugin, ftplugin, etc. directories.
    # entry_script - The Vim script that's runtime'd to initialize the plugin
    #                (optional).
    #
    # Example:
    #
    #   vim.add_plugin 'rails', 'plugin/rails.vim'
    #
    # Returns nothing.
    def add_plugin(dir, entry_script = nil)
      command("set runtimepath+=#{dir}")
      command("runtime #{entry_script}") if entry_script
    end

    def normal(keys = "")
      server.remote_send("<C-\\><C-n>#{keys}")
    end

    # Public: Invokes one of the basic actions the Vim server supports,
    # sending a key sequence. The keys are sent as-is, so it'd probably be
    # better to use the wrapper methods, #normal, #insert and so on.
    #
    # Returns nothing.
    def type(keys)
      server.remote_send(keys)
    end

    # Public: Starts a search in Vim for the given text. The result is that
    # the cursor is positioned on its first occurrence.
    #
    # Returns nothing.
    def search(text)
      normal
      type "/#{text}<CR>"
    end

    # Public: Switches Vim to insert mode and types in the given text.
    #
    # Returns nothing.
    def insert(text)
      normal "i#{text}"
    end

    # Public: Writes the file being edited to disk. Note that you probably
    # want to set the file's name first by using Runner#edit.
    def write
      command :write
    end

    # Public: Echo each expression with a space in between.
    #
    # Returns the String output.
    def echo(*expressions)
      command "echo #{expressions.join(' ')}"
    end

    # Public: Sets a setting in Vim. If +value+ is nil, the setting is
    # considered to be a boolean.
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

    # Public: Edits the file +filename+ with Vim.
    #
    # Note that this doesn't use the '--remote' Vim flag, it simply types in
    # the command manually. This is necessary to avoid the Vim instance
    # getting focus.
    def edit(filename)
      command "edit #{filename}"
    end

    # Public: Executes the given command in the Vim instance and returns its
    # output, stripping all surrounding whitespace.
    #
    # Returns the string output.
    # Raises InvalidCommandError if the command is not recognised by vim.
    def command(commands)
      expression = "VimrunnerEvaluateCommandOutput('#{escape(commands)}')"

      server.remote_expr(expression).tap do |output|
        raise InvalidCommandError if output =~ /^Vim:E\d+:/
      end
    end

    # Kills the server it's connected to.
    def kill
      server.kill
    end

    private

    def escape(string)
      string.to_s.gsub("'", "''")
    end
  end
end
