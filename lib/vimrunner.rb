require 'vimrunner/client'
require 'vimrunner/server'

module Vimrunner
  # Starts a new Server with a terminal Vim instance and returns a client,
  # connected to it.
  def self.start_vim
    Client.new(Server.start)
  end

  # Starts a new Server with a GUI Vim instance and returns a client, connected
  # to it.
  def self.start_gui_vim
    Client.new(Server.start(:gui => true))
  end
end
