require 'timeout'
require 'rbconfig'
require 'pty'

require 'vimrunner/errors'
require 'vimrunner/shell'
require 'vimrunner/client'

module Vimrunner
  class Server
    class << self
      def start(options = {})
        server = new(options)
        server.start
      end

      def new_client
        Client.new(self)
      end

      def list
        %x[#{vim_path} --serverlist].strip.split "\n"
      end

      def vim_path
        if mac? then 'mvim'
        elsif linux? then 'vim'
        else raise UnsupportedOSError.new(host_os)
        end
      end

      def gui_vim_path
        if mac? then 'mvim'
        elsif linux? then 'gvim'
        else raise UnsupportedOSError.new(host_os)
        end
      end

      def vimrc_path
        File.join(File.expand_path('../../..', __FILE__), 'vim', 'vimrc')
      end

      def mac?
        host_os =~ /darwin/
      end

      def linux?
        host_os =~ /linux/
      end

      private

      def host_os
        RbConfig::CONFIG['host_os']
      end
    end

    attr_accessor :pid

    def initialize(options = {})
      @vim_path = options[:vim_path]
      @gui      = options[:gui]
      @name     = options[:name].upcase if options[:name]
    end

    def start
      command = "#{vim_path} -f -u #{Server.vimrc_path} --noplugin --servername #{name}"

      if gui?
        @pid = Kernel.spawn(command, [:in, :out, :err] => :close)
      else
        _out, _in, @pid = PTY.spawn(command)
      end

      wait_until_started
      self
    end

    def vim_path
      @vim_path ||= (gui? ? Server.gui_vim_path : Server.vim_path)
    end

    def name
      @name ||= "VIMRUNNER#{rand.to_s}"
    end

    def gui?
      @gui
    end

    # Kills the vim instance in the background by sending it a TERM signal.
    def kill
      Shell.kill(@pid)
    end

    private

    def wait_until_started
      Timeout.timeout(5, TimeoutError) do
        serverlist = Server.list
        while serverlist.empty? or not serverlist.include? name
          sleep 0.1
          serverlist = Server.list
        end
      end
    end
  end
end
