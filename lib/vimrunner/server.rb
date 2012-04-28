require 'timeout'

require 'vimrunner/errors'
require 'vimrunner/shell'
require 'vimrunner/client'
require 'vimrunner/vim'
require 'vimrunner/driver/gui'
require 'vimrunner/driver/headless'

# TODO (2012-04-28) See if it's possible to avoid referring to drivers directly

module Vimrunner

  # The Server is a wrapper around the Vim server process that is controlled by
  # clients. It will attempt to start the most appropriate Vim binary available
  # on the system, though there are some options that can control this
  # behaviour. See #initialize for more details.
  class Server

    attr_reader :name, :pid, :vim

    # A convenience method that initializes a new server and starts it.
    def self.start(options = {})
      server = new(options)
      server.start
    end

    # A Server is initialized with two options that control its behaviour:
    #
    #   :gui      - Whether or not to start Vim with a GUI, either 'gvim' or 'mvim'
    #               depending on the OS. The default is false, which means that
    #               the server will start itself as a terminal instance. Note
    #               that, if the terminal Vim doesn't have client/server
    #               support, a GUI version will be started anyway.
    #
    #   :vim_path - A path to a custom Vim binary. If this option is not set,
    #               the server attempts to guess an appropriate one, given the
    #               :gui option and the current OS.
    #
    # Note that simply initializing a Server doesn't start the binary. You need
    # to call the #start method to do that.
    #
    # Examples:
    #
    #   server = Server.new                              # Will start a 'vim' if possible
    #   server = Server.new(:gui => true)                # Will start a 'gvim' or 'mvim' depending on the OS
    #   server = Server.new(:vim_path => '/opt/bin/vim') # Will start a server with the given vim instance
    #
    def initialize(options = {})
      vim_path = options[:vim_path]
      gui      = options[:gui]

      @vim = if vim_path && gui
        Driver::Gui.new(vim_path)
      elsif vim_path
        Driver::Headless.new(vim_path)
      elsif gui
        Vim.gui
      else
        Vim.server
      end
    end

    def name
      @name ||= "VIMRUNNER#{rand}"
    end

    def vim_path
      vim.path
    end

    def gui?
      vim.is_a?(Driver::Gui)
    end

    # Starts a Vim server.
    def start
      command = "#{vim_path} -f -u #{vimrc_path} --noplugin --servername #{name}"

      @pid = vim.spawn(command)

      wait_until_started
      self
    end

    # A convenience method that returns a new Client instance, connected to
    # the server.
    def new_client
      Client.new(self)
    end

    # Kills the Vim instance in the background by sending it a TERM signal.
    def kill
      Shell.kill(@pid)
    end

    # Retrieve a list of names of currently running Vim servers.
    def serverlist
      %x[#{vim_path} --serverlist].strip.split "\n"
    end

    # The path to a vimrc file containing some required vimscript. The server
    # is started with no settings or a vimrc, apart from this one.
    def vimrc_path
      File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
    end

    private

    def wait_until_started
      Timeout.timeout(5, TimeoutError) do
        servers = serverlist
        until servers.include?(name)
          sleep 0.1
          servers = serverlist
        end
      end
    end
  end
end
