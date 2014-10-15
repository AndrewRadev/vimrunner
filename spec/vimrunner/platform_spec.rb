require "spec_helper"
require "vimrunner/platform"

module Vimrunner
  RSpec.describe Platform do
    describe "#vim" do
      it "raises an error if no suitable vim could be found" do
        allow(Platform).to receive(:suitable?).and_return(false)

        expect { Platform.vim }.to raise_error(NoSuitableVimError)
      end

      it "returns vim if it supports clientserver and xterm_clipboard" do
        allow(Platform).to receive(:features).and_return("+clientserver +xterm_clipboard")

        expect(Platform.vim).to eq("vim")
      end

      it "returns gvim on Linux if vim doesn't support xterm_clipboard" do
        allow(Platform).to receive(:mac?).and_return(false)
        allow(Platform).to receive(:features) { |vim|
          case vim
          when "vim"
            "+clientserver -xterm_clipboard"
          when "gvim"
            "+clientserver"
          end
        }

        expect(Platform.vim).to eq("gvim")
      end

      it "returns mvim on Mac OS X if vim doesn't support clientserver" do
        allow(Platform).to receive(:mac?).and_return(true)
        allow(Platform).to receive(:features) { |vim|
          case vim
          when "vim"
            "-clientserver -xterm_clipboard"
          when "mvim"
            "+clientserver -xterm_clipboard"
          end
        }

        expect(Platform.vim).to eq("mvim")
      end

      it "ignores versions of vim that do not exist on the system" do
        allow(Platform).to receive(:mac?).and_return(false)
        allow(IO).to receive(:popen) { |command|
          if command == ["vim", "--version"]
            raise Errno::ENOENT
          else
            "+clientserver"
          end
        }

        expect(Platform.vim).to eq("gvim")
      end
    end

    describe "#gvim" do
      it "raises an error if no suitable gvim could be found" do
        allow(Platform).to receive(:suitable?).and_return(false)
        expect { Platform.gvim }.to raise_error(NoSuitableVimError)
      end

      it "returns gvim on Linux" do
        allow(Platform).to receive(:mac?).and_return(false)
        allow(Platform).to receive(:features).and_return("+clientserver")

        expect(Platform.gvim).to eq("gvim")
      end

      it "returns mvim on Mac OS X" do
        allow(Platform).to receive(:mac?).and_return(true)
        allow(Platform).to receive(:features).and_return("+clientserver")

        expect(Platform.gvim).to eq("mvim")
      end
    end
  end
end
