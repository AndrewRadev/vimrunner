require "vimrunner/command"

module Vimrunner
  RSpec.describe Command do
    it "leaves standard commands untouched" do
      expect(Command.new("set linenumber").to_s).to eq("set linenumber")
    end

    it "escapes single quotes" do
      expect(Command.new("echo 'foo'").to_s).to eq("echo ''foo''")
    end
  end
end
