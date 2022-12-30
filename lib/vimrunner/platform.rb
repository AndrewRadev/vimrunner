require "rbconfig"

require "vimrunner/errors"

module Vimrunner

  # Public: The Platform module contains logic for finding a Vim executable
  # that supports the clientserver functionality on the current system. Its
  # methods can be used to fetch a Vim path for initializing a Server.
  #
  # Examples
  #
  #   Vimrunner::Platform.vim
  #   # => "gvim"
  module Platform
    extend self

    # Public: Looks for a Vim executable that's suitable for the current
    # platform. Also attempts to find an appropriate GUI vim if terminal ones
    # are unsuitable.
    #
    # Returns the String Vim executable.
    # Raises NoSuitableVimError if no suitable Vim can be found.
    def vim
      vims.find { |vim| suitable?(vim) } or raise NoSuitableVimError
    end

    # Public: Looks for a Neovim executable that's suitable for the current
    # platform.
    #
    # Returns the String Neovim executable.
    # Raises NoSuitableVimError if no suitable Vim can be found.
    def nvim
      nvims.find { |vim| suitable?(vim) } or raise NoSuitableVimError
    end

    # Public: Looks for a GUI Vim executable that's suitable for the current
    # platform.
    #
    # Returns the String Vim executable.
    # Raises NoSuitableVimError if no suitable Vim can be found.
    def gvim
      gvims.find { |gvim| suitable?(gvim) } or raise NoSuitableVimError
    end

    private

    def gvims
      if mac?
        %w( mvim gvim )
      else
        %w( gvim )
      end
    end

    def vims
      %w( vim ) + gvims
    end

    def nvims
      %w( nvim )
    end

    def suitable?(vim)
      if gui?(vim)
        features(vim).include?("+clientserver")
      elsif neovim?(vim)
        help(vim).include?("--listen")
      else
        features = features(vim)
        features.include?("+clientserver") && features.include?("+xterm_clipboard")
      end
    end

    def gui?(vim)
      executable = File.basename(vim)

      executable[0, 1] == "g" || executable[0, 1] == "m"
    end

    def neovim?(vim)
      File.basename(vim) == 'nvim'
    end

    def features(vim)
      IO.popen([vim, "--version"]) { |io| io.read.strip }
    rescue Errno::ENOENT
      ""
    end

    def help(vim)
      IO.popen([vim, "--help"]) { |io| io.read.strip }
    rescue Errno::ENOENT
      ""
    end

    def mac?
      RbConfig::CONFIG["host_os"] =~ /darwin/
    end
  end
end
