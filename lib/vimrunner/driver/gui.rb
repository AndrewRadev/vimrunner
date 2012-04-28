require 'vimrunner/driver/abstract'

module Vimrunner
  module Driver
    class Gui < Abstract
      def spawn(name)
        command = "#{executable} -f -u #{vimrc_path} --noplugin --servername #{name}"
        Kernel.spawn(command, [:in, :out, :err] => :close)
      end
    end
  end
end
