require "spec_helper"

describe Typed::Schema do
  describe ".schema?" do
    delegate :schema?, :to => "Typed::Schema"

    it "should return true for Class,Module" do
      schema?(Class ).should == true
      schema?(Module).should == true
      schema?(Array ).should == true
      schema?(Hash  ).should == true
      schema?(Fixnum).should == true
    end

    it "should return false for [],{}" do
      schema?([]).should == false
      schema?({}).should == false
    end

    it "should return true for [Class,Module,...]" do
      schema?([Array ]).should == true
      schema?([Hash  ]).should == true
      schema?([Object]).should == true
    end

    it "should return true for {(Class,Module) => (Class,Module)}" do
      schema?({String => Fixnum}).should == true
      schema?({Hash   => Array }).should == true
    end

    it "should return false for instances" do
      schema?(1).should == false
      schema?([1]).should == false
      schema?({:a => 2}).should == false
    end
  end
end
