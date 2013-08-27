require "spec_helper"

describe Typed::Schema do
  describe "#exist?" do
    let(:hash)   { Typed::Hash.new }
    let(:schema) { hash.schema }

    context "(not exist)" do
      specify "false" do
        schema.exist?(:a).should == false
      end
    end

    context "(exist)" do
      before { hash[:a] = String }
      specify "true" do
        schema.exist?(:a).should == true
      end
    end
  end

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
