require "spec_helper"
require "vimrunner"
describe Vimrunner do
  let(:server) { double('server').as_null_object }

  describe "#start" do
    before do
      allow(Vimrunner::Platform).to receive(:vim).and_return("vim")
    end

    it "defaults to using the platform vim" do
      allow(Vimrunner::Server).to receive(:new).with(:executable => "vim").
        and_return(server)
      Vimrunner.start
    end
  end

  describe "#start_gvim" do
    before do
      allow(Vimrunner::Platform).to receive(:gvim).and_return("gvim")
    end

    it "defaults to using the platform gvim" do
      allow(Vimrunner::Server).to receive(:new).with(:executable => "gvim").
        and_return(server)
      Vimrunner.start_gvim
    end
  end

  describe "#connect" do
    let(:server) { Vimrunner::Server.new }

    before(:each) do
      server.start
    end

    it "connects to an existing server by name" do
      vim = Vimrunner.connect(server.name)
      expect(vim.server.name).to eq(server.name)
    end

    after(:each) do
      server.kill
    end
  end
end

