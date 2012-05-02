require "vimrunner/server"
require "vimrunner/platform"

module Vimrunner
  describe Server do
    let(:server) { Server.new(Platform.vim) }

    describe "#start" do
      it "starts a vim server process" do
        begin
          server.start
          server.serverlist.should include(server.name)
        ensure
          server.kill
        end
      end

      it "can start more than one vim server process" do
        begin
          first = Server.new(Platform.vim)
          second = Server.new(Platform.vim)

          first.start
          second.start

          first.serverlist.should include(first.name, second.name)
        ensure
          first.kill
          second.kill
        end
      end
    end

    describe "#remote_expr" do
      it "uses the server's executable to send remote expressions"
    end

    describe "#remote_send" do
      it "uses the server's executable to send remote keys"
    end
  end
end
