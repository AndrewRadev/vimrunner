require 'spec_helper'
require 'vimrunner/server'

module Vimrunner
  describe Server do
    it "can start a vim server process" do
      server = Server.start
      server.serverlist.should include(server.name)
      server.kill
    end

    it "can start more than one vim server process" do
      begin
        first  = Server.start
        second = Server.start

        first.serverlist.should include(first.name, second.name)
      ensure
        first.kill
        second.kill
      end
    end

    describe "#new_client" do
      around do |example|
        begin
          @server = Server.start
          example.call
        ensure
          @server.kill
        end
      end

      it "returns a client" do
        @server.new_client.should be_a(Client)
      end

      it "is attached to the server" do
        @server.new_client.server.should == @server
      end
    end

    describe "#vim_path" do
      it "can be explicitly overridden" do
        server = Server.new(:vim_path => '/opt/local/bin/vim')
        server.vim_path.should eq '/opt/local/bin/vim'
      end
    end
  end
end
