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
      vims.select { |v| gui?(v) }
    end

    def vims
      if mac?
        ["vim", "mvim -v", "mvim", "gvim"]
      else
        ["vim", "gvim"]
      end + shell_aliases
    end

    def shell_aliases
      [shell_vim_alias, shell_vim_alias_without_args]
    end

    def shell_vim_alias
      `source ~/.profile; source ~/.bash_profile; source ~/.bashrc; alias vim`[/'(.+)'/, 1]
    end

    def shell_vim_alias_without_args
      shell_vim_alias && shell_vim_alias[/^[^ ]+/]
    end

    def suitable?(vim)
      features = features(vim)

      if gui?(vim)
        features.include?("+clientserver")
      else
        features.include?("+clientserver") && features.include?("+xterm_clipboard")
      end
    end

    def gui?(vim)
      if vim
        executable = File.basename(vim)

        gvim_or_mvim_without_shell_switch?(executable)
      end
    end

    def gvim_or_mvim_without_shell_switch?(executable)
      executable.include?("gvim") || (
        executable.include?("mvim") && executable !~ / -v\b/
      )
    end

    def features(vim)
      `#{vim} --version` || ""
    rescue Errno::ENOENT
      ""
    end

    def mac?
      RbConfig::CONFIG["host_os"] =~ /darwin/
    end
  end
end
