require 'vimrunner/client'
require 'vimrunner/server'

module Vimrunner
  def self.start_vim
    Client.new(Server.start)
  end

  def self.start_gui_vim
    Client.new(Server.start(:gui => true))
  end
end
