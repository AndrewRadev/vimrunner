module Vimrunner
  class Command
    def initialize(command)
      @command = command
    end

    def to_s
      @command.to_s.gsub("'", "''")
    end
    alias_method :to_str, :to_s
  end
end
