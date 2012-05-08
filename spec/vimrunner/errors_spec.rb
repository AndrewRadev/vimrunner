require "spec_helper"
require "vimrunner/errors"

module Vimrunner
  describe NoSuitableVimError do
    it "has a useful message" do
      expect {
        raise NoSuitableVimError
      }.to raise_error("No suitable Vim executable could be found for this system.")
    end
  end

  describe TimeoutError do
    it "has a useful message" do
      expect {
        raise TimeoutError
      }.to raise_error("Timed out while waiting for serverlist. Is an X11 server running?")
    end
  end
end
