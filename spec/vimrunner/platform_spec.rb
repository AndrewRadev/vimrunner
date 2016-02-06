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
        allow(Platform).to receive(:features) do |vim|
          case vim
          when "vim"
            "+clientserver -xterm_clipboard"
          else
            "+clientserver +xterm_clipboard"
          end
        end

        expect(Platform.vim).to eq("gvim")
      end

      it "returns mvim on Mac OS X if console vims don't support clientserver" do
        allow(Platform).to receive(:mac?).and_return(true)
        allow(Platform).to receive(:features) do |vim|
          if vim == 'mvim'
            "+clientserver -xterm_clipboard"
          else
            "-clientserver -xterm_clipboard"
          end
        end

        expect(Platform.vim).to eq("mvim")
      end

      it "returns console mvim on Mac OS X if it supports what vim doesn't" do
        allow(Platform).to receive(:mac?).and_return(true)
        allow(Platform).to receive(:features) do |vim|
          if vim == 'mvim -v'
            "+clientserver +xterm_clipboard"
          else
            "+clientserver -xterm_clipboard"
          end
        end

        expect(Platform.vim).to eq("mvim -v")
      end

      it "ignores versions of vim that do not exist on the system" do
        allow(Platform).to receive(:mac?).and_return(false)
        allow(Platform).to receive(:`) do |command|
          if command == ["vim", "--version"]
            raise Errno::ENOENT
          else
            "+clientserver"
          end
        end

        expect(Platform.vim).to eq("gvim")
      end
    end

    describe "#gvim" do
      it "raises an error if no suitable gvim could be found" do
        allow(Platform).to receive(:suitable?) do |vim|
          ['vim', 'mvim -v'].include?(vim)
        end

        expect { Platform.gvim }.to raise_error(NoSuitableVimError)
      end

      it "returns gvim on Linux" do
        allow(Platform).to receive(:mac?).and_return(false)
        allow(Platform).to receive(:features).
          and_return("+clientserver +xterm_clipboard")

        expect(Platform.gvim).to eq("gvim")
      end

      it "returns mvim on Mac OS X" do
        allow(Platform).to receive(:mac?).and_return(true)
        allow(Platform).to receive(:features).
          and_return("+clientserver +xterm_clipboard")

        expect(Platform.gvim).to eq("mvim")
      end
    end
  end
end
