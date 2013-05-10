require "vimrunner/path"

module Vimrunner
  describe Path do
    it "leaves standard paths untouched" do
      Path.new("foo.txt").to_s.should eq("foo.txt")
    end

    it "escapes non-standard characters in paths" do
      Path.new("foo bar!.txt").to_s.should eq('foo\ bar\!.txt')
    end

    it "acts mostly as a string" do
      ("one " + Path.new("two")).should eq('one two')
    end
  end
end
