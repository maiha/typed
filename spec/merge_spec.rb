require "spec_helper"

describe Typed::Hash do
  describe "#merge!" do
    context "(empty)" do
      it "should merge given hash as same as Hash" do
        data = Typed::Hash.new
        data.merge!("a" => 1, :b => "x")
        data.keys.sort.should == ["a", "b"]
        data["a"].should == 1
        data["b"].should == "x"
      end
    end

    context "(elements exist)" do
      it "should merge given hash as same as Hash" do
        data = Typed::Hash.new
        data["a"] = 1

        data.merge!("a" => 2, :b => "x", :c => [])
        data.keys.sort.should == ["a", "b", "c"]
        data["a"].should == 2
        data["b"].should == "x"
        data["c"].should == []
      end
    end
  end
end
