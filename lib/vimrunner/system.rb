require 'rbconfig'

require 'vimrunner/driver/gui'
require 'vimrunner/driver/headless'

module Vimrunner
  module System
    extend self

    def choose_driver(vim_path, force_gui)
      if vim_path && force_gui
        Driver::Gui.new(vim_path)
      elsif vim_path
        Driver::Headless.new(vim_path)
      elsif force_gui
        gui_driver
      else
        headless_driver
      end
    end

    def gui_driver
      if mac?
        Driver::Gui.new("mvim")
      else
        Driver::Gui.new("gvim")
      end
    end

    def headless_driver
      if clientserver?("vim") && xterm_clipboard?("vim")
        Driver::Headless.new("vim")
      elsif mac?
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
