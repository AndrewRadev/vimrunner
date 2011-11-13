require 'spec_helper'
require 'vimrunner/shell'

module Vimrunner
  describe Shell do
    it "can execute an external command and return the output" do
      Shell.run('echo', 'foo').should eq 'foo'
      Shell.run('echo', 'bar baz').should eq 'bar baz'
    end

    it "can kill a process by its PID" do
      pid = Process.fork { sleep 1; exit(42) }

      Shell.kill(pid).should be_true

      Process.wait(pid)
      $?.exitstatus.should_not eq 42
    end

    it "can safely attempt to kill a non-existent process" do
      pid = Process.fork { exit }
      Process.wait(pid)
      Shell.kill(pid).should be_false
    end
  end
end
