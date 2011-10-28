require 'vimrunner/shell'
require 'vimrunner/errors'

module Vimrunner

  # The Runner class acts as the actual proxy to a vim instance. Upon
  # initialization, a vim process is started in the background. The Runner
  # instance's public methods correspond to actions the instance will perform.
  #
  # Use Runner#kill to manually destroy the background process.
  class Runner
    class << self
      def start_gvim
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

      def vimrc_path
        File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
      end
    end

    def initialize(pid)
      @pid = pid
      wait_until_started
    end

    def type(keys)
      invoke_vim '--remote-send', keys
    end

    # Executes +vim_command+ in the vim instance and returns its output,
    # stripping all surrounding whitespace.
    def command(vim_command)
      normal

      invoke_vim('--remote-expr', "VimrunnerEvaluateCommandOutput('#{vim_command.to_s}')").strip.tap do |output|
        raise InvalidCommandError if output =~ /^Vim:E\d+:/
      end
    end

    # Starts a search in vim for the given text. The result is that the cursor
    # is positioned on its first occurrence.
    def search(text)
      normal
      type "/#{text}<cr>"
    end

    def edit(filename)
      normal
      type ":e #{filename}<cr>"
    end

    def write
      normal
      type ':w<cr>'
    end

    def insert(text = '')
      normal
      type "i#{text}"
    end

    def normal(text = '')
      type "<c-\\><c-n>#{text}"
    end

    def quit
      normal
      type 'ZZ'
    end

    # Kills the vim instance in the background by sending it a TERM signal.
    def kill
      Shell.kill(@pid)
    end

    # Ensures that vim has finished with its previous action. This is useful
    # when a command has been sent to the vim instance that might take a little
    # while, and we need to check the results of the command.
    #
    # Example:
    #
    #   runner.write
    #   runner.wait_until_ready
    #   # Provided there was no error, the file should now be written
    #   # successfully
    #
    def wait_until_ready
      command :echo
    end

    private

    def serverlist
      %x[vim --serverlist].strip.split '\n'
    end

    def invoke_vim(*args)
      args = ['vim', '--servername', 'VIMRUNNER', *args]
      Shell.run *args
    end

    def wait_until_started
      while serverlist.empty? or not serverlist.include? 'VIMRUNNER'
        sleep 0.1
      end
    end
  end
end
