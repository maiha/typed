require "spec_helper"

describe Typed::Hash do
  def data
    subject
  end

  context "(Object schema)" do
    it "should accept []" do
      data["a"] = Object
      lambda {
        data["a"] = []
      }.should_not raise_error
      data["a"].should == []
      data.schema("a").should == Object
    end

    it "should accept ['x']" do
      data["a"] = Object
      lambda {
        data["a"] = ['x']
      }.should_not raise_error
      data["a"].should == ['x']
      data.schema("a").should == Object
    end
  end
end
