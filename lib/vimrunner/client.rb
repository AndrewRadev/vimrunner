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
    # Examples
    #
    #   vim.add_plugin 'rails', 'plugin/rails.vim'
    #
    # Returns nothing.
    def add_plugin(dir, entry_script = nil)
      append_runtimepath(dir)
      command("runtime #{entry_script}") if entry_script
    end

    # Public: Appends a directory to Vim's runtimepath
    #
    # dir - The directory added to the path
    #
    # Returns nothing.
    def append_runtimepath(dir)
      command("set runtimepath+=#{dir}")
    end

    # Public: Prepends a directory to Vim's runtimepath. Use this instead of
    # #append_runtimepath to give the directory higher priority when Vim
    # runtime's a file.
    #
    # dir - The directory added to the path
    #
    # Returns nothing.
    def prepend_runtimepath(dir)
      runtimepath = echo '&runtimepath'
      command("set runtimepath=#{dir},#{runtimepath}")
    end

    # Public: Switches Vim to normal mode and types in the given keys.
    #
    # Returns the Client instance.
    def normal(keys = "")
      server.remote_send("<C-\\><C-n>#{keys}")
      self
    end

    # Public: Invokes one of the basic actions the Vim server supports,
    # sending a key sequence. The keys are sent as-is, so it'd probably be
    # better to use the wrapper methods, #normal, #insert and so on.
    #
    # Returns the Client instance.
    def type(keys)
      server.remote_send(keys)
      self
    end

    # Public: Starts a search in Vim for the given text. The result is that
    # the cursor is positioned on its first occurrence.
    #
    # Returns the Client instance.
    def search(text)
      normal
      type "/#{text}<CR>"
    end

    # Public: Switches Vim to insert mode and types in the given text.
    #
    # Returns the Client instance.
    def insert(text)
      normal "i#{text}"
    end

    # Public: Writes the file being edited to disk. Note that you probably
    # want to set the file's name first by using Runner#edit.
    #
    # Returns the Client instance.
    def write
      command :write
      self
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
    # Examples
    #
    #   vim.set 'expandtab'  # invokes ":set expandtab"
    #   vim.set 'tabstop', 3 # invokes ":set tabstop=3"
    #
    # Returns the Client instance
    def set(setting, value = nil)
      if value
        command "set #{setting}=#{value}"
      else
        command "set #{setting}"
      end
      self
    end

    # Public: Edits the file +filename+ with Vim.
    #
    # Note that this doesn't use the '--remote' Vim flag, it simply types in
    # the command manually. This is necessary to avoid the Vim instance
    # getting focus.
    #
    # Returns the Client instance.
    def edit(filename)
      command "edit #{filename}"
      self
    end

    # Public: Edits the file +filename+ with Vim using edit!.
    #
    # Similar to #edit, only discards any changes to the current buffer.
    #
    # Returns the Client instance.
    def edit!(filename)
      command "edit! #{filename}"
      self
    end

    # Public: Executes the given command in the Vim instance and returns its
    # output, stripping all surrounding whitespace.
    #
    # Returns the String output.
    # Raises InvalidCommandError if the command is not recognised by vim.
    def command(commands)
      expression = "VimrunnerEvaluateCommandOutput('#{escape(commands)}')"

      server.remote_expr(expression).tap do |output|
        raise InvalidCommandError.new(output) if output =~ /^Vim:E\d+:/
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
