require "vimrunner/errors"

require "rbconfig"

module Vimrunner
  module Platform
    extend self

    def vim
      vims.find { |vim| suitable?(vim) } or raise NoSuitableVimError
    end

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
