require "spec_helper"
require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner
  describe Server do
    let(:server) { Server.new }

    describe "#initialize" do
      it "defaults to using Platform.vim for the executable" do
        server.executable.should eq(Platform.vim)
      end

      it "defaults to a random name" do
        server.name.should start_with("VIMRUNNER")
      end

      it "ensures that its server name is uppercase" do
        server = Vimrunner::Server.new(:name => "foo")
        server.name.should eq("FOO")
      end
    end

    describe "#start" do
      it "starts a vim server process" do
        begin
          server.start
          server.serverlist.should include(server.name)
        ensure
          server.kill
          server.serverlist.should_not include(server.name)
        end
      end

      it "can start more than one vim server process" do
        begin
          first = Server.new
          second = Server.new

          first.start
          second.start

          first.serverlist.should include(first.name, second.name)
        ensure
          first.kill
          second.kill
        end
      end

      it "can start a vim server process with a block" do
        server.start do |client|
          server.serverlist.should include(server.name)
        end

        server.serverlist.should_not include(server.name)
      end
    end

    describe "connecting to an existing server" do
      before(:each) do
        server.start
      end

      let(:second_server) { Server.new(:name => server.name) }

      it "returns a client" do
        second_server.connect.should be_a(Client)
        second_server.connect!.should be_a(Client)
      end

      it "returns a client connected to the named server" do
        second_server.connect.server.should eq(second_server)
        second_server.connect!.server.should eq(second_server)
      end

      describe "#connect" do
        it "returns nil if no server is found in :timeout seconds" do
          server = Server.new(:name => 'NONEXISTENT')
          server.connect(:timeout => 0.1).should be_nil
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
        server.should be_running
      end

      it "returns true if the given name corresponds to a running Vim instance" do
        server.start
        other_server = Server.new(:name => server.name)

        other_server.should be_running
      end
    end

    describe "#new_client" do
      it "returns a client" do
        server.new_client.should be_a(Client)
      end

      it "is attached to the server" do
        server.new_client.server.should == server
      end
    end

    describe "#remote_expr" do
      it "uses the server's executable to send remote expressions" do
        server.should_receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-expr", "version"])

        server.remote_expr("version")
      end
    end

    describe "#remote_send" do
      it "uses the server's executable to send remote keys" do
        server.should_receive(:execute).
          with([server.executable, "--servername", server.name,
               "--remote-send", "ihello"])

        server.remote_send("ihello")
      end
    end

    describe "#serverlist" do
      it "uses the server's executable to list servers" do
        server.should_receive(:execute).
          with([server.executable, "--serverlist"]).and_return("VIM")

        server.serverlist
      end

      it "splits the servers into an array" do
        server.stub(:execute => "VIM\nVIM2")

        server.serverlist.should == ["VIM", "VIM2"]
      end
    end
  end
end
