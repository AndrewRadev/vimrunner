require 'rbconfig'

require 'vimrunner/gui_vim'
require 'vimrunner/headless_vim'

module Vimrunner
  module Vim
    extend self

    def server
      if clientserver?("vim") && xterm_clipboard?("vim")
        HeadlessVim.new("vim")
      elsif mac?
        GuiVim.new("mvim")
      else
        GuiVim.new("gvim")
      end
    end

    def client
      if mac? && !clientserver?("vim")
        GuiVim.new("mvim")
      else
        HeadlessVim.new("vim")
      end
    end

    def gui
      if mac?
        GuiVim.new("mvim")
      else
        GuiVim.new("gvim")
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
