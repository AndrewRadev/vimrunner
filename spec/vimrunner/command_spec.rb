require "vimrunner/command"

module Vimrunner
  describe Command do
    it "leaves standard commands untouched" do
      Command.new("set linenumber").to_s.should eq("set linenumber")
    end

    it "escapes single quotes" do
      Command.new("echo 'foo'").to_s.should eq("echo ''foo''")
    end
  end
end
