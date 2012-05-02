require "spec_helper"

describe Typed::Changes do
  describe "#keys" do
    it "should return []" do
      subject.keys.should == []
    end

    it "should return [:a] after touch(:a)" do
      subject.touch(:a)
      subject.keys.should == ["a"]
    end

    it "should return [:a,:b] after touch(:a) and touch(:b)" do
      subject.touch(:a)
      subject.touch(:b)
      subject.keys.should == ["a", "b"]
    end

    it "should return [:b,:a] after touch(:b) and touch(:a)" do
      subject.touch(:b)
      subject.touch(:a)
      subject.keys.should == ["b", "a"]
    end

    it "should return [:a] after touch(:a) twice" do
      subject.touch(:a)
      subject.touch(:a)
      subject.keys.should == ["a"]
    end

    it "should return [] after touch(:a) and reset" do
      subject.touch(:a)
      subject.reset
      subject.keys.should == []
    end
  end
end
