require 'vimrunner/driver/abstract'

module Vimrunner
  module Driver
    class Gui < Abstract
      def spawn(command)
        Kernel.spawn(command, [:in, :out, :err] => :close)
      end
    end
  end
end
