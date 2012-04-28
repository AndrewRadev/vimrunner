require 'spec_helper'
require 'vimrunner/driver/abstract'

module Vimrunner
  class TestDriver < Driver::Abstract
    def spawn
    end
  end

  describe TestDriver do
    let(:driver) { TestDriver.new('vim') }

    it "can run a shell command with the given executable and return the output" do
      driver.run('--version').should include("VIM")
      driver.run('--help').should include("usage")
    end

    it "can kill a process by its PID" do
      pid = Process.fork { sleep 1; exit(42) }

      driver.kill(pid).should be_true

      Process.wait(pid)
      $?.exitstatus.should_not eq 42
    end

    it "can safely attempt to kill a non-existent process" do
      pid = Process.fork { exit }
      Process.wait(pid)
      driver.kill(pid).should be_false
    end
  end
end
