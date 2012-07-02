require "spec_helper"

describe Typed::Hash do
  def data
    subject
  end

  ######################################################################
  ### Accessor

  it "should behave like hash" do
    data["a"] = 1
    data["b"] = 2
    data.keys.sort.should == ["a", "b"]
    data.values.sort.should == [1, 2]
  end

  it "should behave like hash with lazy values" do
    data["a"] = 1
    data.default("b") { 2 }
    data.keys.sort.should == ["a", "b"]
    data.values.sort.should == [1, 2]
  end

  it "should stringify keys" do
    data["a"] = 1
    data[:a].should == 1
    data[:a] = 2
    data["a"].should == 2
  end

  describe "#[]" do
    it "should raise NotDefined if value not exists" do
      lambda {
        data["foo"]
      }.should raise_error(Typed::NotDefined)
    end

    it "should return value if exists" do
      data["foo"] = 1
      data["foo"].should == 1
    end
  end

  describe "#[]=" do
    it "should accept as schema when class is given" do
      data[:foo] = String
      data.exist?(:foo).should == false

      data[:bar] = Hash
      data.exist?(:bar).should == false
    end

    it "should check schema if exists" do
      data[:foo] = String
      data[:foo] = "foo"
      lambda {
        data[:foo] = 1
      }.should raise_error(TypeError)
    end

    it "should implicitly declare schema when assigned" do
      data[:foo] = 1
      data.schema(:foo).should == Fixnum

      data[:bar] = {:a => 1}
      data.schema(:bar).should == {Symbol => Fixnum}
    end

    it "should implicitly declare schema if not exists" do
      data[:foo] = 1
      data.schema(:foo).should == Fixnum
    end

    # TODO: How can we declare Boolean? How to treat nil?
    it "should not implicitly declare schema when nil,true,false" do
      data[:foo] = nil
      data.schema(:foo).should == nil

      data[:bar] = true
      data.schema(:bar).should == nil

      data[:baz] = false
      data.schema(:baz).should == nil
    end

    it "can override existing value if same type" do
      data[:foo] = 1
      data[:foo] = 2
      data[:foo].should == 2
    end

    it "cannot override existing value when type mismatch" do
      data[:foo] = 1            # Fixnum
      lambda {
        data[:foo] = 0.5        # Float
      }.should raise_error(TypeError)
    end

    it "can override existing value if declared by common ancestor" do
      data[:foo] = Numeric
      data[:foo] = 1
      data[:foo] = 0.5
      data[:foo].should == 0.5
    end

    it "should create new objects for Array,Hash is given for schema" do
      data[:a] = []
      data[:a][0] = 1
      data.schema(:a).should == Array

      data[:h] = {}
      data[:h]["x"] = 1
      data.schema(:h).should == Hash
    end

    it "should check existing value when explicit declarement is given" do
      data[:foo] = {}
      data[:foo][:a] = 1
      lambda {
        data[:foo] = {String => Integer}
      }.should raise_error(TypeError)
    end

    it "cannot ovreride explicit declarement" do
      data[:num] = Numeric
      lambda {
        data[:num] = Fixnum
      }.should raise_error(TypeError)
    end

    it "should accept atomic class (like Fixnum) for its schema" do
      data[:foo] = 1
      lambda {
        data[:foo] = Fixnum
      }.should_not raise_error
    end

    it "should accept complex classes (like [Fixnum]) for its schema" do
      data[:foo] = [1]
      lambda {
        data[:foo] = [Fixnum]
      }.should_not raise_error
    end

    it "should accept complex classes (like {String=>Fixnum}) for its schema" do
      data[:foo] = {"a" => 1}
      lambda {
        data[:foo] = {String => Fixnum}
      }.should_not raise_error
    end

    it "can override implicitly declared schema by sub-struct schema" do
      data[:foo] = {}
      data[:foo].should == {}
      data.schema(:foo).should == Hash

      data[:foo] = {String => Integer}
      data[:foo].should == {}
      data.schema(:foo).should == {String => Integer}
    end

    it "should implicitly override schema when given schema is sub-struct of existing one" do
      data[:foo] = {}
      data[:foo].should == {}
      data.schema(:foo).should == Hash

      data[:foo] = {:a => 1}
      data[:foo].should == {:a => 1}
      data.schema(:foo).should == {Symbol => Fixnum}
    end

    it "should not override schema if explicitly declarement exists" do
      data[:foo] = Hash
      data[:foo] = {}
      data.schema(:foo).should == Hash

      data[:foo] = {:a => 1}
      data[:foo].should == {:a => 1}
      data.schema(:foo).should == Hash
    end

    it "raise TypeError when re-declarement causes type mismatch" do
      data[:foo] = Numeric
      data[:foo] = 0.5
      lambda {
        data[:foo] = Fixnum
      }.should raise_error(TypeError)
    end
  end

  ######################################################################
  ### Reflection

  describe "#schema(key)" do
    it "should return its schema(type class)" do
      data[:num] = 1
      data.schema(:num).should == Fixnum
    end
  end

  ######################################################################
  ### Testing

  describe "#exist?" do
    it "should return true if the value is set" do
      data[:foo] = 1
      data.exist?(:foo).should == true
    end

    it "should return false if the value is not set" do
      data.exist?(:foo).should == false
    end
  end

  describe "#set?" do
    it "should return true if the value is set and not (nil|false)" do
      data[:foo] = 0
      data.set?(:foo).should == true

      data.default[:bar] = 0
      data.set?(:bar).should == true

      data.default(:baz) { 0 }
      data.set?(:baz).should == true
    end

    it "should return false if the value is set but (nil|false)" do
      data[:foo] = nil
      data.set?(:foo).should == false

      data[:foo] = false
      data.set?(:foo).should == false
    end
  end

  describe "#check" do
    it "should satisfy its type" do
      data[:foo] = 1
      lambda {
        data.check(:foo, Integer)
      }.should_not raise_error
    end

    it "should satisfy its struct" do
      data[:foo] = {:a => "text"}
      lambda {
        data.check(:foo, {Symbol => String})
      }.should_not raise_error
    end

    it "should raise TypeError if not satisfied" do
      data[:foo] = {:a => "text"}
      lambda {
        data.check(:foo, Integer)
      }.should raise_error(TypeError)
    end
  end

  ######################################################################
  ### Default values

  describe "#default" do
    it "should set default value" do
      data.default[:foo] = 1
      data.exist?(:foo).should == true
      data[:foo].should == 1
    end

    it "should be overriden by []=" do
      data.default[:foo] = 1
      data[:foo] = 2
      data[:foo].should == 2
    end

    it "should not affect data when already set" do
      data[:foo] = 1
      data.default[:foo] = 2
      data[:foo].should == 1
    end
  end

  describe "#default(&block)" do
    it "should set lazy default value" do
      @a = 1
      data.default(:foo) { @a }
      @a = 2
      data[:foo].should == 2
    end

    it "should freeze lazy default value once accessed" do
      @a = 1
      data.default(:foo) { @a }
      @a = 2
      data[:foo].should == 2
      @a = 3
      data[:foo].should == 2
    end
  end

  ######################################################################
  ### Changes

  describe "#changes" do
    its(:changes) {should be_kind_of(Typed::Changes)}
  end
end

