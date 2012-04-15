module Vimrunner
  class InvalidCommandError < RuntimeError; end

  class NoClientServerError < RuntimeError
    def message
      "Vim needs to be compiled with +clientserver"
    end
  end

  class TimeoutError < RuntimeError
    def message
      "Timed out while waiting for serverlist. Is an X11 server running?"
    end
  end
end
