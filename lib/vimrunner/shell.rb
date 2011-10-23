module Vimrunner

  # The Shell module contains functions that interact directly with the shell.
  # Some of them are general utilities, others are vim-specific.
  module Shell
    extend self

    # Executes a shell command, waits until it's finished, and returns the
    # output
    def run(*command)
      IO.popen(command) { |io| io.read.strip }
    end
  end
end
