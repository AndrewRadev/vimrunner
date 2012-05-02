require "vimrunner/platform"

module Vimrunner
  describe Platform do
    describe "#vim" do
      it "raises an error if no suitable vim could be found" do
        Platform.stub(:suitable? => false)

        expect { Platform.vim }.to raise_error(NoSuitableVimError)
      end

      it "returns vim if it supports clientserver and xterm_clipboard" do
        Platform.stub(:features => "+clientserver +xterm_clipboard")

        Platform.vim.should == "vim"
      end

      it "returns gvim on Linux if vim doesn't support xterm_clipboard" do
        Platform.stub(:mac? => false)
        Platform.stub(:features) { |vim|
          case vim
          when "vim"
            "+clientserver -xterm_clipboard"
          when "gvim"
            "+clientserver"
          end
        }

        Platform.vim.should == "gvim"
      end

      it "returns mvim on Mac OS X if vim doesn't support clientserver" do
        Platform.stub(:mac? => true)
        Platform.stub(:features) { |vim|
          case vim
          when "vim"
            "-clientserver -xterm_clipboard"
          when "mvim"
            "+clientserver -xterm_clipboard"
          end
        }

        Platform.vim.should == "mvim"
      end
    end

    describe "#gvim" do
      it "raises an error if no suitable gvim could be found" do
        Platform.stub(:suitable? => false)
        expect { Platform.gvim }.to raise_error(NoSuitableVimError)
      end

      it "returns gvim on Linux" do
        Platform.stub(:mac? => false)
        Platform.stub(:features => "+clientserver")

        Platform.gvim.should == "gvim"
      end

      it "returns mvim on Mac OS X" do
        Platform.stub(:mac? => true)
        Platform.stub(:features => "+clientserver")

        Platform.gvim.should == "mvim"
      end
    end
  end
end
