require "timeout"
require "pty"

require "vimrunner/errors"
require "vimrunner/client"

module Vimrunner
  class Server
    VIMRC = File.expand_path("../../../vim/vimrc", __FILE__)

    attr_reader :name, :executable

    def initialize(executable)
      @executable = executable
      @name = "VIMRUNNER#{rand}"
    end

    def start
      if block_given?
        spawn do |r, w, pid|
          begin
            wait_until_started
            @result = yield(new_client)
          ensure
            r.close
            w.close
          end
        end

        @result
      else
        @r, @w, @pid = spawn
        wait_until_started

        new_client
      end
    end

    # Kills the Vim instance in the background.
    def kill
      @r.close
      @w.close
      Process.detach(@pid)

      self
    end

    # A convenience method that returns a new Client instance, connected to
    # the server.
    def new_client
      Client.new(self)
    end

    # Retrieve a list of names of currently running Vim servers.
    def serverlist
      execute([executable, "--serverlist"]).split("\n")
    end

    def remote_expr(expression)
      execute([executable, "--servername", name, "--remote-expr", expression])
    end

    def remote_send(keys)
      execute([executable, "--servername", name, "--remote-send", keys])
    end

    private

    def execute(command)
      IO.popen(command) { |io| io.read.strip }
    end

    def spawn(&blk)
      PTY.spawn(executable, "-f", "--servername", name, "-u", VIMRC, &blk)
    end

    def wait_until_started
      Timeout.timeout(5, TimeoutError) do
        sleep 0.1 while !serverlist.include?(name)
      end
    end
  end
end
