require 'spec_helper'
require 'vimrunner/vim'

module Vimrunner
  describe Vim do
    let(:gvim) { GuiVim.new("gvim") }
    let(:mvim) { GuiVim.new("mvim") }
    let(:vim)  { HeadlessVim.new("vim") }

    describe "#gui" do
      it "returns mvim on Mac OS X" do
        Vim.stub(:mac? => true)
        Vim.gui.should == mvim
      end

      it "returns gvim on Linux" do
        Vim.stub(:mac? => false)
        Vim.gui.should == gvim
      end
    end

    context "with a +clientserver vim" do
      before do
        Vim.stub(:clientserver? => true)
      end

      context "with -xterm_clipboard" do
        before do
          Vim.stub(:xterm_clipboard? => false)
        end

        context "on Mac OS X" do
          before do
            Vim.stub(:mac? => true)
          end

          it "uses mvim for the server" do
            Vim.server.should == mvim
          end

          it "uses vim for the client" do
            Vim.client.should == vim
          end
        end

        context "on Linux" do
          before do
            Vim.stub(:mac? => false)
          end

          it "uses gvim for the server" do
            Vim.server.should == gvim
          end

          it "uses vim for the client" do
            Vim.client.should == vim
          end
        end
      end

      context "with +xterm_clipboard" do
        before do
          Vim.stub(:xterm_clipboard? => true)
        end

        it "uses vim for the server" do
          Vim.server.should == vim
        end

        it "uses vim for the client" do
          Vim.client.should == vim
        end
      end
    end

    context "with a -clientserver vim" do
      before do
        Vim.stub(:clientserver? => false)
      end

      context "on Mac OS X" do
        before do
          Vim.stub(:mac? => true)
        end

        it "uses mvim for the server" do
          Vim.server.should == mvim
        end

        it "uses mvim for the client" do
          Vim.server.should == mvim
        end
      end

      context "on Linux" do
        before do
          Vim.stub(:mac? => false)
        end

        it "uses gvim for the server" do
          Vim.server.should == gvim
        end

        it "uses gvim for the client" do
          Vim.server.should == gvim
        end
      end
    end
  end
end
