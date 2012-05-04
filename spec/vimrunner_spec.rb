require "spec_helper"
require "vimrunner"

describe Vimrunner do
  let(:server) { double('server').as_null_object }

  describe "#start" do
    before do
      Vimrunner::Platform.stub(:vim => "vim")
    end

    it "defaults to using the platform vim" do
      Vimrunner::Server.should_receive(:new).with("vim").and_return(server)

      Vimrunner.start
    end
  end

  describe "#start_gvim" do
    before do
      Vimrunner::Platform.stub(:gvim => "gvim")
    end

    it "defaults to using the platform gvim" do
      Vimrunner::Server.should_receive(:new).with("gvim").and_return(server)

      Vimrunner.start_gvim
    end
  end
end

