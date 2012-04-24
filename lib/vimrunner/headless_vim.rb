require 'pty'

require 'vimrunner/vim_instance'

module Vimrunner
  class HeadlessVim < VimInstance
    def spawn(command)
      _r, _w, pid = PTY.spawn(command)

      pid
    end
  end
end
