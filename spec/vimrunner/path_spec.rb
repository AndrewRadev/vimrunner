require "vimrunner/path"

module Vimrunner
  RSpec.describe Path do
    it "leaves standard paths untouched" do
      expect(Path.new("foo.txt").to_s).to eq("foo.txt")
    end

    it "escapes non-standard characters in paths" do
      expect(Path.new("foo bar!.txt").to_s).to eq('foo\ bar\!.txt')
    end
  end
end
