require "timeout"
require "pty"

require "vimrunner/errors"
require "vimrunner/client"
require "vimrunner/platform"

module Vimrunner

  # Public: A Server has the responsibility of starting a Vim process and
  # communicating with it through the clientserver interface. The process can
  # be started with "start" and stopped with "kill". If given the servername of
  # an existing Vim instance, it can control that instance without the need to
  # start a new process.
  #
  # A Client would be necessary as the actual interface, though it is possible
  # to use a Server directly to invoke --remote commands on its Vim instance.
  class Server
    VIMRC = File.expand_path("../../../vim/vimrc", __FILE__)
    VIMRUNNER_RC = File.expand_path("../../../vim/vimrunner_rc", __FILE__)

    attr_reader :name, :executable, :vimrc

    # Public: Initialize a Server
    #
    # options - The Hash options used to define a server (default: {}):
    #           :executable - The String Vim executable to use (optional)
    #                         (default: Platform.vim).
    #           :name       - The String name of the Vim server (optional)
    #                         (default: "VIMRUNNER#{rand}").
    def initialize(options = {})
      @executable = options.fetch(:executable) { Platform.vim }
      @name       = options.fetch(:name) { "VIMRUNNER#{rand}" }
      @vimrc      = options.fetch(:vimrc) { VIMRC }
      @foreground = options.fetch(:foreground, true)
    end

    # Public: Start a Server. This spawns a background process.
    #
    # Examples
    #
    #   client = Vimrunner::Server.new("vim").start
    #   # => #<Vimrunner::Client>
    #
    #   Vimrunner::Server.new("vim").start do |client|
    #     client.edit("foo")
    #   end
    #
    # Returns a new Client instance initialized with this Server.
    # Yields a new Client instance initialized with this Server.
    def start
      @r, @w, @pid = spawn
      if block_given?
        begin
          @result = yield(connect)
        ensure
          r.close
          w.close
          Process.kill(9, pid) rescue Errno::ESRCH
        end
        @result
      else
        connect
      end
    end

    # Public: Connects to the running server by name, blocking if need be.
    #
    # Returns a new Client instance initialized with this Server.
    def connect(options = {})
      if !connected? && options[:spawn]
        @r, @w, @pid = spawn
      end
      wait_until_started

      client = new_client
      client.feedkeys(":\\<C-u>source #{client.fesc(VIMRUNNER_RC)}\\<CR>")

      return client
    end

    # Public: Checks if the server is connected to a running Vim instance.
    #
    # Returns a Boolean
    def connected?
      serverlist.include?(name)
    end

    # Public: Kills the Vim instance in the background.
    #
    # Returns self.
    def kill
      @r.close
      @w.close
      Process.kill(9, @pid) rescue Errno::ESRCH

      self
    end

    # Public: A convenience method that returns a new Client instance,
    # connected to this server.
    #
    # Returns a Client.
    def new_client
      Client.new(self)
    end

    # Public: Retrieves a list of names of currently running Vim servers.
    #
    # Returns an Array of String server names currently running.
    def serverlist
      execute([executable, "--serverlist"]).split("\n")
    end

    # Public: Evaluates an expression in the Vim server and returns the result.
    # A wrapper around --remote-expr.
    #
    # expression - a String with a Vim expression to evaluate.
    #
    # Returns the String output of the expression.
    def remote_expr(expression)
      execute([executable, "--servername", name, "--remote-expr", expression])
    end

    # Public: Sends the given keys
    # A wrapper around --remote-expr.
    #
    # keys - a String with a sequence of Vim-compatible keystrokes.
    #
    # Returns nothing.
    def remote_send(keys)
      execute([executable, "--servername", name, "--remote-send", keys])
    end

    private

    def foreground_option
      @foreground ? '-f' : ''
    end

    def execute(command)
      IO.popen(command) { |io| io.read.strip }
    end

    def spawn
      PTY.spawn("#{executable} #{foreground_option} --servername #{name} -u #{vimrc}")
    end

    def wait_until_started
      Timeout.timeout(5, TimeoutError) do
        sleep 0.1 while !connected?
      end
    end
  end
end
