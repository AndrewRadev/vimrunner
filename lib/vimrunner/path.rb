module Vimrunner
  class Path < ::String
    def initialize(path)
      super
    end

    def to_s
      super.to_s.gsub(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")
    end
  end
end

