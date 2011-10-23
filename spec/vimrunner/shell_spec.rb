require 'spec_helper'
require 'vimrunner/shell'

module Vimrunner
  describe Shell do
    it "can execute an external command and return the output" do
      Shell.run('echo', 'foo').should eq 'foo'
    end
  end
end
