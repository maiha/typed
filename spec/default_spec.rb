require "spec_helper"

describe Typed::Default do
  describe "#merge" do
    it "should merge to hash" do
      data = Typed::Hash.new
      data.default.merge!(:a=>1, :b=>2)
      data.keys.sort.should == ["a", "b"]
      data["a"].should == 1
      data["b"].should == 2
    end

    it "should merge to hash only when the key is not set" do
      data = Typed::Hash.new
      data[:a] = 10

      data.default.merge!(:a=>1, :b=>2)
      data.keys.sort.should == ["a", "b"]
      data["a"].should == 10
      data["b"].should == 2
    end
  end
end

