require 'pty'
require 'vimrunner/shell'
require 'vimrunner/errors'

module Vimrunner

  # The Runner class acts as the actual proxy to a vim instance. Upon
  # initialization, a vim process is started in the background. The Runner
  # instance's public methods correspond to actions the instance will perform.
  #
  # Use Runner#kill to manually destroy the background process.
  class Runner
    attr_reader :servername

    class << self
      def start_gvim
        servername = "VIMRUNNER#{rand.to_s}"
        command    = "gvim -f -u #{vimrc_path} --noplugin --servername #{servername}"
        pid        = spawn(command, [:in, :out, :err] => :close)

        new(pid, servername)
      end

      def start_vim
        servername     = "VIMRUNNER#{rand.to_s}"
        command        = "vim -f -u #{vimrc_path} --noplugin --servername #{servername}"
        _out, _in, pid = PTY.spawn(command)

        new(pid, servername)
      end

      def vimrc_path
        File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
      end

      def serverlist
        %x[vim --serverlist].strip.split "\n"
      end
    end

    def initialize(pid, servername)
      @pid        = pid
      @servername = servername
      wait_until_started
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

    # Writes the file being edited to disk. Note that you need to set the
    # file's name first by using Runner#edit.
    def write
      command :write
    end

    # Switches vim to insert mode and types in the given text.
    def insert(text = '')
      normal "i#{text}"
    end

    # Switches vim to insert mode and types in the given keys.
    def normal(keys = '')
      type "<c-\\><c-n>#{keys}"
    end

    # Kills the vim instance in the background by sending it a TERM signal.
    def kill
      Shell.kill(@pid)
    end

    private

    def invoke_vim(*args)
      args = ['vim', '--servername', @servername, *args]
      Shell.run *args
    end

    def wait_until_started
      serverlist = Runner.serverlist
      while serverlist.empty? or not serverlist.include? @servername
        sleep 0.1
        serverlist = Runner.serverlist
      end
    end
  end
end
