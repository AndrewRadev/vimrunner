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

    describe "#vim_path" do
      before :each do
        Server.stub(:clientserver_enabled? => true)
      end

      it "can be explicitly overridden" do
        server = Server.new(:vim_path => '/opt/local/bin/vim')
        server.vim_path.should eq '/opt/local/bin/vim'
      end

      describe "(with GUI)" do
        let(:server) { Server.new(:gui => true) }

        it "defaults to 'mvim' on Mac OS X" do
          Server.stub(:mac? => true)
          server.vim_path.should eq 'mvim'
        end

        it "defaults to 'gvim' on Linux" do
          Server.stub(:mac? => false)
          server.vim_path.should eq 'gvim'
        end
      end

      describe "(without GUI)" do
        let(:server) { Server.new(:gui => false) }

        it "defaults to 'vim' on Mac OS X" do
          Server.stub(:mac? => true)
          server.vim_path.should eq 'vim'
        end

        it "defaults to 'vim' on Linux" do
          Server.stub(:mac? => false)
          server.vim_path.should eq 'vim'
        end

        it "is not registered as a GUI" do
          server.should_not be_gui
        end
      end

      describe "(without GUI, but without +clientserver)" do
        let(:server) { Server.new(:gui => false) }

        it "falls back to GUI vim" do
          Server.stub(:clientserver_enabled? => false, :mac? => false)
          server.vim_path.should eq 'gvim'
        end

        it "is registered as a GUI" do
          Server.stub(:clientserver_enabled? => false, :mac? => false)
          server.should be_gui
        end
      end
    end
  end
end
