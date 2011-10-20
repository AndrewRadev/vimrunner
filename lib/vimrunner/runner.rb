module Vimrunner
  # The Runner class acts as the actual proxy to a vim instance. Upon
  # initialization, a vim process is started in the background. The Runner
  # instance's public methods correspond to actions the instance will perform.
  # Use Runner#kill to manually destroy the background process.
  class Runner
    attr_reader :executable

    def initialize(vim_executable = 'vim')
      @executable = vim_executable

      child_stdin,   parent_stdin = IO::pipe
      parent_stdout, child_stdout = IO::pipe
      parent_stderr, child_stderr = IO::pipe

      @pid = Kernel.fork do
        [parent_stdin, parent_stdout, parent_stderr].each { |io| io.close }

        STDIN.reopen(child_stdin)
        STDOUT.reopen(child_stdout)
        STDERR.reopen(child_stderr)

        [child_stdin, child_stdout, child_stderr].each { |io| io.close }

        exec @executable, '--servername', 'VIMRUNNER'
      end

      [child_stdin, child_stdout, child_stderr].each { |io| io.close }
      parent_stdin.sync = true
      Process.wait
    end

    def edit(filename)
      normal
      type ":e #{filename}<cr>"
    end

    def insert
      normal
      type 'i'
    end

    def normal
      type '<c-\\><c-n>'
    end

    def type(keys)
      run executable, '--servername', 'VIMRUNNER', '--remote-send', keys
    end

    def write
      normal
      type ':w<cr>'
    end

    def quit
      normal
      type 'ZZ'
    end

    def kill
      if running?
        Process.kill(Signal.list['TERM'], @pid)
        true
      end
    end

    def running?
      return false unless @pid
      Process.getpgid(@pid)
      true
    rescue Errno::ESRCH
      false
    end

    private

    def run(*params)
      system *params
    end
  end
end
