module Vimrunner
  class Path
    def initialize(path)
      @path = path
    end

    def to_s
      @path.to_s.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")
    end
  end
end
