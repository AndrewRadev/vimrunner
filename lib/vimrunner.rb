require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner
  def self.start(vim = Platform.vim, &blk)
    Server.new(vim).start(&blk)
  end

  def self.start_gvim(&blk)
    Server.new(Platform.gvim).start(&blk)
  end
end
