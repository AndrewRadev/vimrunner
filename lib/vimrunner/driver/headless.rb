require 'pty'

require 'vimrunner/driver/abstract'

module Vimrunner
  module Driver
    class Headless < Abstract
      def spawn(name)
        command = "#{executable} -u #{vimrc_path} --noplugin --servername #{name}"
        _r, _w, pid = PTY.spawn(command)

        pid
      end
    end
  end
end
