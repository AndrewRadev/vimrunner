require "spec_helper"
require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner
  RSpec.describe Server do
    let(:server) { Server.new }

    describe "#initialize" do
      it "defaults to using Platform.vim for the executable" do
        expect(server.executable).to eq(Platform.vim)
      end

      it "defaults to a random name" do
        expect(server.name).to start_with("VIMRUNNER")
      end

      it "ensures that its server name is uppercase" do
        server = Vimrunner::Server.new(:name => "foo")
        expect(server.name).to eq("FOO")
      end
    end

    describe "#start" do
      it "starts a vim server process" do
        begin
          server.start
          expect(server.serverlist).to include(server.name)
        ensure
          server.kill
          expect(server.serverlist).to_not include(server.name)
        end
      end

      it "can start more than one vim server process" do
        begin
          first = Server.new
          second = Server.new

          first.start
          second.start

          expect(first.serverlist).to include(first.name, second.name)
        ensure
          first.kill
          second.kill
        end
      end

      it "can start a vim server process with a block" do
        server.start do |client|
          expect(server.serverlist).to include(server.name)
        end

        expect(server.serverlist).to_not include(server.name)
      end
    end

    describe "connecting to an existing server" do
      before(:each) do
        server.start
      end

      let(:second_server) { Server.new(:name => server.name) }

      it "returns a client" do
        expect(second_server.connect).to be_a(Client)
        expect(second_server.connect!).to be_a(Client)
      end

      it "returns a client connected to the named server" do
        expect(second_server.connect.server).to eq(second_server)
        expect(second_server.connect!.server).to eq(second_server)
      end

      describe "#connect" do
        it "returns nil if no server is found in :timeout seconds" do
          server = Server.new(:name => 'NONEXISTENT')
          expect(server.connect(:timeout => 0.1)).to be_nil
        end
      end

      describe "#connect!" do
        it "raises an error if no server is found in :timeout seconds" do
          server = Server.new(:name => 'NONEXISTENT')
          expect {
            server.connect!(:timeout => 0.1)
          }.to raise_error(TimeoutError)
        end
      end
    end

    describe "#running?" do
      it "returns true if the server started successfully" do
        server.start
        expect(server).to be_running
      end

      it "returns true if the given name corresponds to a running Vim instance" do
        server.start
        other_server = Server.new(:name => server.name)

        expect(other_server).to be_running
      end
    end

    describe "#new_client" do
      it "returns a client" do
        expect(server.new_client).to be_a(Client)
      end

      it "is attached to the server" do
        expect(server.new_client.server).to eq(server)
      end
    end

    describe "#remote_expr" do
      it "uses the server's executable to send remote expressions" do
        expect(server).to receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-expr", "version"])

        server.remote_expr("version")
      end

      it "fails with a ExecutionError if the executable writes anything to stderr" do
        expect(server).to receive(:name).and_return('WRONG_NAME')
        expect {
          server.remote_expr("version")
        }.to raise_error(ExecutionError, /E247:/)
      end
    end

    describe "#remote_send" do
      it "uses the server's executable to send remote keys" do
        expect(server).to receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-send", "ihello"])

        server.remote_send("ihello")
      end

      it "fails with a ExecutionError if the executable writes anything to stderr" do
        expect(server).to receive(:name).and_return('WRONG_NAME')
        expect {
          server.remote_send("ihello")
        }.to raise_error(ExecutionError, /E247:/)
      end
    end

    describe "#serverlist" do
      it "uses the server's executable to list servers" do
        expect(server).to receive(:execute).
          with([server.executable, "--serverlist"]).and_return("VIM")

        server.serverlist
      end

      it "splits the servers into an array" do
        allow(server).to receive(:execute).and_return("VIM\nVIM2")

        expect(server.serverlist).to eq(["VIM", "VIM2"])
      end
    end

    describe "pid" do
      it "returns the pid of the server" do
        server.start
        expect(server.pid).not_to be(nil)
      end
    end
  end
end
