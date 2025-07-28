require "timeout"
require "pty"
require "open3"

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
  # A Client would be necessary as an actual interface, though it is possible
  # to use a Server directly to invoke --remote commands on its Vim instance.
  class Server
    VIMRC        = File.expand_path("../../../vim/vimrc", __FILE__)
    VIMRUNNER_RC = File.expand_path("../../../vim/vimrunner.vim", __FILE__)

    attr_reader :name, :full_name, :executable, :vimrc, :gvimrc, :pid

    # Public: Initialize a Server
    #
    # options - The Hash options used to define a server (default: {}):
    #           :executable - The String Vim executable to use (optional)
    #                         (default: Platform.vim).
    #           :name       - The String name of the Vim server (optional)
    #                         (default: "VIMRUNNER#{rand}").
    #           :vimrc      - The String vimrc file to source in the client (optional)
    #                         (default: Server::VIMRC).
    #           :foreground - Boolean, whether to start Vim with the -f option (optional)
    #                         (default: true).
    #
    # The `:full_name` attribute reader will provide the name prefixed with the
    # system's temporary file directory. The reason is that Neovim uses the
    # "name" as a UNIX domain socket.
    #
    def initialize(options = {})
      @executable = options.fetch(:executable) { Platform.vim }
      @name       = options.fetch(:name) { "VIMRUNNER#{rand}" }.upcase
      @vimrc      = options.fetch(:vimrc) { VIMRC }
      @gvimrc     = options.fetch(:gvimrc) { "NONE" }
      @foreground = options.fetch(:foreground, true)

      @full_name = File.join(Dir.tmpdir, @name)
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
          @result = yield(connect!)
        ensure
          kill
        end
        @result
      else
        connect!
      end
    end

    # Public: Connects to the running server by name, blocking if need be.
    # Returns nil if no server was found in the given time.
    #
    # options - An optional Hash. For now, only used for specifying a timeout
    #           (default: {}):
    #
    #           :timeout - The Integer timeout to wait for a running server (optional)
    #                      (default: 5).
    #
    # Returns a new Client instance initialized with this Server.
    def connect(options = {})
      connect!(options)
    rescue TimeoutError
      nil
    end

    # Public: Connects to the running server by name, blocking if need be.
    # Raises a TimeoutError if no server was found in the given time in
    # seconds.
    #
    # options - An optional Hash. For now, only used for specifying a timeout
    #           (default: {}):
    #
    #           :timeout - The Integer timeout to wait for a running server
    #                      (default: 5).
    #
    # Returns a new Client instance initialized with this Server.
    def connect!(options = {})
      wait_until_running(options[:timeout] || 5)

      client = new_client
      client.source(VIMRUNNER_RC)
      client
    end

    # Public: Checks if there's a running Vim instance with the server's name.
    #
    # Returns a Boolean
    def running?
      serverlist.include?(full_name)
    end

    # Public: Kills the Vim instance in the background.
    #
    # Returns self.
    def kill
      @r.close
      @w.close

      begin
        Process.kill(9, @pid)
      rescue Errno::ESRCH
      end

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
      if neovim?
        execute([executable, "-es", '+"verbose echo string(serverlist())"'])
      else
        execute([executable, "--serverlist"]).split("\n")
      end
    end

    # Public: Evaluates an expression in the Vim server and returns the result.
    # A wrapper around --remote-expr.
    #
    # expression - a String with a Vim expression to evaluate.
    #
    # Returns the String output of the expression.
    def remote_expr(expression)
      if neovim?
        execute([executable, "--server", full_name, "--remote-expr", expression])
      else
        execute([executable, "--servername", full_name, "--remote-expr", expression])
      end
    end

    # Public: Sends the given keys
    # A wrapper around --remote-send.
    #
    # keys - a String with a sequence of Vim-compatible keystrokes.
    #
    # Returns nothing.
    def remote_send(keys)
      execute([executable, "--servername", full_name, "--remote-send", keys])
    end

    private

    def neovim?
      executable == 'nvim'
    end

    def foreground_option
      @foreground ? '-f' : ''
    end

    def execute(command)
      puts command.inspect
      out, err, status = Open3.capture3(*command)
      puts [out, err, status].inspect
      if not err.empty?
        raise ExecutionError.new("Command failed (#{command}), output: #{err}")
      end

      out.chomp.gsub(/\A\n/, '')
    end

    def spawn
      PTY.spawn(executable, *%W[
        #{foreground_option}
        --servername #{full_name}
        -u #{vimrc}
        -U #{gvimrc}
        -i NONE
        --noplugin
      ])
    end

    def wait_until_running(seconds)
      Timeout.timeout(seconds, TimeoutError) do
        sleep 0.1 while !running?
      end
    end
  end
end
