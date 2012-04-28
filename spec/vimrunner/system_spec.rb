require 'spec_helper'
require 'vimrunner/system'

module Vimrunner
  describe System do
    let(:gvim) { Driver::Gui.new("gvim") }
    let(:mvim) { Driver::Gui.new("mvim") }
    let(:vim)  { Driver::Headless.new("vim") }

    describe "#gui_driver" do
      it "returns mvim on Mac OS X" do
        System.stub(:mac? => true)
        System.gui_driver.should == mvim
      end

      it "returns gvim on Linux" do
        System.stub(:mac? => false)
        System.gui_driver.should == gvim
      end
    end

    context "with a +clientserver vim" do
      before do
        System.stub(:clientserver? => true)
      end

      context "with -xterm_clipboard" do
        before do
          System.stub(:xterm_clipboard? => false)
        end

        context "on Mac OS X" do
          before do
            System.stub(:mac? => true)
          end

          it "uses mvim as a headless driver" do
            System.headless_driver.should == mvim
          end
        end

        context "on Linux" do
          before do
            System.stub(:mac? => false)
          end

          it "uses gvim as a headless driver" do
            System.headless_driver.should == gvim
          end
        end
      end

      context "with +xterm_clipboard" do
        before do
          System.stub(:xterm_clipboard? => true)
        end

        it "uses vim as a headless driver" do
          System.headless_driver.should == vim
        end
      end
    end

    context "with a -clientserver vim" do
      before do
        System.stub(:clientserver? => false)
      end

      context "on Mac OS X" do
        before do
          System.stub(:mac? => true)
        end

        it "uses mvim as a headless driver" do
          System.headless_driver.should == mvim
        end
      end

      context "on Linux" do
        before do
          System.stub(:mac? => false)
        end

        it "uses gvim as a headless driver" do
          System.headless_driver.should == gvim
        end
      end
    end
  end
end
