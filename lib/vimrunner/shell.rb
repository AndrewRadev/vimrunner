module Vimrunner

  # The Shell module contains functions that interact directly with the shell.
  # They're general utilities that help with some of the specific use cases
  # that pop up with the vim runner.
  module Shell
    extend self

    # Executes a shell command, waits until it's finished, and returns the
    # output
    def run(*command)
      IO.popen(command) { |io| io.read.strip }
    end

    # Sends a TERM signal to the given PID if it corresponds to a running
    # process.
    def kill(pid)
      Process.kill(Signal.list['TERM'], pid) if running?(pid)
    end

    private

    # Checks if the given PID corresponds to a running process
    def running?(pid)
      return false if pid.nil?
      Process.getpgid(pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end
