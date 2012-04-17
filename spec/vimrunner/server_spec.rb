require 'spec_helper'
require 'vimrunner/server'

module Vimrunner
  describe Server do
    it "can start a vim server process" do
      server = Server.start

      Server.list.should include(server.name)

      server.kill
    end

    it "can start more than one vim server process" do
      begin
        first  = Server.start
        second = Server.start

        Server.list.should include(first.name, second.name)
      ensure
        first.kill
        second.kill
      end
    end

    it "can be given a specific name" do
      server = Server.start(:name => 'example')
      Server.list.should include('EXAMPLE')
      server.kill
    end

    describe "#vim_path" do
      it "can be explicitly overridden" do
        server = Server.new(:vim_path => '/opt/local/bin/vim')
        server.vim_path.should eq '/opt/local/bin/vim'
      end

      it "raises an exception on an unsupported system" do
        expect {
          Server.stub(:mac? => false, :linux? => false)
          Server.start
        }.to raise_error
      end

      describe "(without GUI)" do
        let(:server) { Server.new(:gui => false) }

        it "defaults to 'mvim' on Mac OS X" do
          Server.stub(:mac? => true)
          server.vim_path.should eq 'mvim'
        end

        it "defaults to 'vim' on Linux" do
          Server.stub(:linux? => true)
          server.vim_path.should eq 'vim'
        end
      end

      describe "(with GUI)" do
        let(:server) { Server.new(:gui => true) }

        it "defaults to 'mvim' on Mac OS X" do
          Server.stub(:mac? => true)
          server.vim_path.should eq 'mvim'
        end

        it "defaults to 'gvim' on Linux" do
          Server.stub(:linux? => true)
          server.vim_path.should eq 'gvim'
        end
      end
    end
  end
end
