require "spec_helper"

describe Typed::Hash do
  let(:data) { Typed::Hash.new }

  describe "#time" do
    it "should return a Time when it is a Fixnum" do
      data["now"] = Time.mktime(2012,5,15).to_i
      data.time("now").should == Time.mktime(2012,5,15)
    end

    it "should return itself when it is a Time" do
      data["now"] = Time.mktime(2012,5,15)
      data.time("now").should == Time.mktime(2012,5,15)
    end

    it "should raise Must::Invalid if not time-able" do
      data["now"] = "x"

      lambda {
        data.time("now")
      }.should raise_error(Must::Invalid)
    end
  end
end

