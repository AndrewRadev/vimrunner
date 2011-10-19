module Vimrunner
  # The Runner class acts as the actual proxy to a vim instance. Upon
  # initialization, a vim process is started in the background. The Runner
  # instance's public methods correspond to actions the instance will perform.
  # Use Runner#kill to manually destroy the background process.
  class Runner
    def kill
    end
  end
end
