require "spec_helper"
require "vimrunner/platform"

module Vimrunner
  RSpec.describe Platform do
    let(:vim_alias) { "/Applications/mvim -v" }
    let(:gvim_alias) { "/Applications/mvim" }

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
          if vim == "mvim"
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
          if vim == "mvim -v"
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

      context 'with aliases' do
        before do
          allow(Platform).to receive(:`).with(
            "source ~/.profile; source ~/.bash_profile; source ~/.bashrc; alias vim"
          ).and_return("alias vim='#{vim_alias}'")
        end

        it "returns vim alias if normal executables aren't suitable" do
          allow(Platform).to receive(:suitable?) do |vim|
            !["vim", "mvim -v", "mvim", "gvim"].include?(vim)
          end

          expect(Platform.vim).to eq(vim_alias)
        end

        it "return gvim alias if even vim alias is not suitable" do
          allow(Platform).to receive(:suitable?) do |vim|
            !["vim", "mvim -v", "mvim", "gvim", vim_alias].include?(vim)
          end

          expect(Platform.vim).to eq(gvim_alias)
        end
      end
    end

    describe "#gvim" do
      it "raises an error if only console vims are suitable" do
        allow(Platform).to receive(:suitable?) do |vim|
          ["vim", "mvim -v"].include?(vim)
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

      context 'with aliases' do
        before do
          allow(Platform).to receive(:`).with(
            "source ~/.profile; source ~/.bash_profile; source ~/.bashrc; alias vim"
          ).and_return("alias vim='#{vim_alias}'")
        end

        it "returns gvim alias if nothing else works" do
          allow(Platform).to receive(:suitable?) do |vim|
            !["gvim", "mvim"].include?(vim)
          end

          expect(Platform.gvim).to eq(gvim_alias)
        end
      end
    end
  end
end
