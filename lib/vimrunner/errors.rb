module Vimrunner
  class InvalidCommandError < RuntimeError; end

  class TimeoutError < RuntimeError
    def message
      "Timed out while waiting for serverlist. Is an X11 server running?"
    end
  end
end
