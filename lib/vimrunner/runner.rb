module Vimrunner
  # The Runner class acts as the actual proxy to a vim instance. Upon
  # initialization, a vim process is started in the background. The Runner
  # instance's public methods correspond to actions the instance will perform.
  #
  # Use Runner#kill to manually destroy the background process.
  class Runner
    def self.start_gvim
      child_stdin,   parent_stdin = IO::pipe
      parent_stdout, child_stdout = IO::pipe
      parent_stderr, child_stderr = IO::pipe

      pid = Kernel.fork do
        [parent_stdin, parent_stdout, parent_stderr].each { |io| io.close }

        STDIN.reopen(child_stdin)
        STDOUT.reopen(child_stdout)
        STDERR.reopen(child_stderr)

        [child_stdin, child_stdout, child_stderr].each { |io| io.close }

        exec 'gvim', '-f', '-u', vimrc_path, '--noplugin', '--servername', 'VIMRUNNER'
      end

      [child_stdin, child_stdout, child_stderr].each { |io| io.close }

      new(pid)
    end

    def self.vimrc_path
      File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
    end

    def initialize(pid)
      @pid = pid
      wait_until_ready
    end

    def wait_until_ready
      while serverlist.empty? or not serverlist.include? 'VIMRUNNER'
        sleep 0.1
      end
    end

    def serverlist
      %x[vim --serverlist].strip.split '\n'
    end

    def command(name)
      normal
      invoke_vim('--remote-expr', "EvaluateCommandOutput('#{name.to_s}')").strip
    end

    def edit(filename)
      normal
      type ":e #{filename}<cr>"
    end

    def insert(text)
      normal
      type "i#{text}"
    end

    def normal
      type '<c-\\><c-n>'
    end

    def type(keys)
      invoke_vim '--remote-send', keys
    end

    def invoke_vim(*args)
      args = ['vim', '--servername', 'VIMRUNNER'] + args
      Shell.run *args
    end

    def write
      normal
      type ':w<cr>'
    end

    def quit
      normal
      type 'ZZ'
    end

    def sync
      command :echo
    end

    def kill
      Process.kill(Signal.list['TERM'], @pid) if running?
    end

    def running?
      return false unless @pid
      Process.getpgid(@pid)
      true
    rescue Errno::ESRCH
      false
    end
  end
end
