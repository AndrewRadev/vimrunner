module Vimrunner
  class InvalidCommandError < RuntimeError; end
  class NoSuitableVimError < RuntimeError
    def message
      "No suitable Vim executable could be found for this system."
    end
  end
  class TimeoutError < RuntimeError
    def message
      "Timed out while waiting for serverlist. Is an X11 server running?"
    end
  end
end
