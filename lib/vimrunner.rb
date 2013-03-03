require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner

  # Public: Start a Vim process and return a Client through which it can be
  # controlled.
  #
  # vim - The String path to the Vim you wish to use (default: the most
  #       appropriate Vim for your system).
  # blk - An optional block which will be passed a Client with which you can
  #       communicate with the Vim process. Upon exiting the block, the Vim
  #       process will be terminated.
  #
  # Examples
  #
  #   client = Vimrunner.start
  #   # => #<Vimrunner::Client>
  #
  #   Vimrunner.start do |client|
  #     client.command("version")
  #   end
  #
  # Returns a Client for the started Server.
  def self.start(vim = Platform.vim, &blk)
    Server.new(:executable => vim).start(&blk)
  end

  # Public: Start a Vim process with a GUI and return a Client through which
  # it can be controlled.
  #
  # vim - The String path to the Vim you wish to use (default: the most
  #       appropriate Vim for your system).
  # blk - An optional block which will be passed a Client with which you can
  #       communicate with the Vim process. Upon exiting the block, the Vim
  #       process will be terminated.
  #
  # Examples
  #
  #   client = Vimrunner.start
  #   # => #<Vimrunner::Client>
  #
  #   Vimrunner.start do |client|
  #     client.command("version")
  #   end
  #
  # Returns a Client for the started Server.
  def self.start_gvim(&blk)
    Server.new(:executable => Platform.gvim).start(&blk)
  end
end
