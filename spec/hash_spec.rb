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

  describe "#[]" do
    it "should return value if exists" do
      data[:foo] = 1
      data[:foo].should == 1
    end

    it "should raise NotDefined if value not exists" do
      lambda {
        data[:foo]
      }.should raise_error(Typed::NotDefined)
    end
  end

  describe "#[]=" do
    it "should set not data but schema when schema given" do
      data[:foo] = String
      data.exist?(:foo).should == false
    end

    it "should check schema if exists" do
      data[:foo] = String

      lambda {
        data[:foo] = "foo"
      }.should_not raise_error(TypeError)

      lambda {
        data[:foo] = 1
      }.should raise_error(TypeError)
    end

    it "should check schema if exists" do
      data[:foo] = String

      lambda {
        data[:foo] = "foo"
      }.should_not raise_error(TypeError)

      lambda {
        data[:foo] = 1
      }.should raise_error(TypeError)
    end

    it "should guess and check schema if not exists" do
      data[:foo] = 1
      lambda {
        data[:foo] = "test"
      }.should raise_error(TypeError)
    end

    it "can override existing value if same type" do
      data[:foo] = 1
      data[:foo] = 2
      data[:foo].should == 2
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
end

