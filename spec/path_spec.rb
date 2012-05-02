require "spec_helper"

describe Typed::Hash do
  describe "#path" do
    it "should return a Pathname when it is a String" do
      data = Typed::Hash.new
      data["dir"] = "tmp/foo"

      data.path("dir").should == Pathname("tmp/foo")
    end

    it "should return itself when it is a Pathname" do
      data = Typed::Hash.new
      data["dir"] = Pathname("tmp/foo")

      data.path("dir").should == Pathname("tmp/foo")
    end

    it "should raise Must::Invalid if not pathname-able" do
      data = Typed::Hash.new
      data["dir"] = 10

      lambda {
        data.path("dir")
      }.should raise_error(Must::Invalid)
    end
  end
end

