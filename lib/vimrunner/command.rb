module Vimrunner
  class Command
    def initialize(command)
      @command = command
    end

    def to_s
      @command.to_s.gsub("'", "''")
    end
  end
end
