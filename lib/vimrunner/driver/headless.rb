require 'pty'

require 'vimrunner/driver/abstract'

module Vimrunner
  module Driver
    class Headless < Abstract
      def spawn(command)
        _r, _w, pid = PTY.spawn(command)

        pid
      end
    end
  end
end
