require 'rbconfig'

require 'vimrunner/driver/gui'
require 'vimrunner/driver/headless'

module Vimrunner
  module Vim
    extend self

    def server
      if clientserver?("vim") && xterm_clipboard?("vim")
        Driver::Headless.new("vim")
      elsif mac?
        Driver::Gui.new("mvim")
      else
        Driver::Gui.new("gvim")
      end
    end

    def client
      if mac? && !clientserver?("vim")
        Driver::Gui.new("mvim")
      else
        Driver::Headless.new("vim")
      end
    end

    def gui
      if mac?
        Driver::Gui.new("mvim")
      else
        Driver::Gui.new("gvim")
      end
    end

    private

    def mac?
      /darwin/ === RbConfig::CONFIG['host_os']
    end

    def clientserver?(vim)
      supports?(vim, "clientserver")
    end

    def xterm_clipboard?(vim)
      supports?(vim, "xterm_clipboard")
    end

    def supports?(vim, feature)
      %x[#{vim} --version].include?("+#{feature}")
    end
  end
end
