require 'vimrunner/vim_instance'

module Vimrunner
  class GuiVim < VimInstance
    def spawn(command)
      Kernel.spawn(command, [:in, :out, :err] => :close)
    end
  end
end
