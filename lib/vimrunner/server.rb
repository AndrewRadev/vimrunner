require 'timeout'
require 'rbconfig'
require 'pty'

require 'vimrunner/errors'
require 'vimrunner/shell'
require 'vimrunner/client'

module Vimrunner

  # The Server is a wrapper around the Vim server process that is controlled by
  # clients. It will attempt to start the most appropriate Vim binary available
  # on the system, though there are some options that can control this
  # behaviour. See #initialize for more details.
  class Server
    class << self

      # A convenience method that initializes a new server and starts it.
      def start(options = {})
        server = new(options)
        server.start
      end

      # A convenience method that returns a new Client instance, connected to
      # the server.
      def new_client
        Client.new(self)
      end

      # Retrieve a list of names of currently running Vim servers.
      def list
        %x[#{vim_path} --serverlist].strip.split "\n"
      end

      # The default path to use when starting a server with a terminal Vim. If
      # the "vim" executable is not compiled with clientserver capabilities,
      # the GUI version is started instead.
      def vim_path
        'vim'
      end

      # The default path to use when starting a server with the GUI version of
      # Vim. Defaults to "mvim" on a mac and "gvim" on linux.
      def gui_vim_path
        if mac?
          'mvim'
        else
          'gvim'
        end
      end

      # The path to a vimrc file containing some required vimscript. The server
      # is started with no settings or a vimrc, apart from this one.
      def vimrc_path
        File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
      end

      # Returns true if the current operating system is Mac OS X.
      def mac?
        host_os =~ /darwin/
      end

      # Returns true if the given Vim binary is compiled with support for the
      # client/server functionality.
      def clientserver_enabled?(vim_path)
        vim_version = %x[#{vim_path} --version]
        vim_version.include? '+clientserver' and vim_version.include? '+xterm_clipboard'
      end

      private

      def host_os
        RbConfig::CONFIG['host_os']
      end
    end

    attr_accessor :pid
    attr_reader :name, :vim_path

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
      @gui = options.fetch(:gui) { false }
      @vim_path = options.fetch(:vim_path) do
        if @gui or not Server.clientserver_enabled? Server.vim_path
          @gui = true
          Server.gui_vim_path
        else
          Server.vim_path
        end
      end
      @name = "VIMRUNNER#{rand.to_s}"
    end

    # Starts a Vim server.
    def start
      command = "#{vim_path} -f -u #{Server.vimrc_path} --noplugin --servername #{name}"

      if gui?
        @pid = Kernel.spawn(command, [:in, :out, :err] => :close)
      else
        _out, _in, @pid = PTY.spawn(command)
      end

      wait_until_started
      self
    end

    # Returns true if the server is a GUI version of Vim. This can be forced by
    # instantiating the server with :gui => true
    def gui?
      @gui
    end

    # Kills the Vim instance in the background by sending it a TERM signal.
    def kill
      Shell.kill(@pid)
    end

    private

    def wait_until_started
      Timeout.timeout(5, TimeoutError) do
        serverlist = Server.list
        while serverlist.empty? or not serverlist.include? name
          sleep 0.1
          serverlist = Server.list
        end
      end
    end
  end
end
