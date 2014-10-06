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
      if mac?
        %w( mvim gvim )
      else
        %w( gvim )
      end
    end

    def vims
      %w( vim ) + gvims
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
      executable = File.basename(vim)

      executable[0, 1] == "g" || executable[0, 1] == "m"
    end

    def features(vim)
      IO.popen([vim, "--version"]) { |io| io.read.strip }
    rescue Errno::ENOENT
      ""
    end

    def mac?
      RbConfig::CONFIG["host_os"] =~ /darwin/
    end
  end
end
