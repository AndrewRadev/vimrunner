require 'rbconfig'

require 'vimrunner/driver/gui'
require 'vimrunner/driver/headless'

module Vimrunner
  module System
    extend self

    def choose_driver(vim_path, force_gui)
      vim_path ||= default_vim_path(force_gui)

      headless_driver = Driver::Headless.new(vim_path)
      gui_driver      = Driver::Gui.new(vim_path)

      if force_gui or not headless_driver.suitable?
        gui_driver
      else
        headless_driver
      end
    end

    def default_vim_path(force_gui)
      if mac?
        'mvim'
      elsif force_gui
        'gvim'
      else
        'vim'
      end
    end

    private

    def mac?
      /darwin/ === RbConfig::CONFIG['host_os']
    end
  end
end
