require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

  ######################################################################
  ### Basic usage

  describe "User" do
    before { scala_source("User", <<-EOF)
      class User
        include Typed::Scala

        val key  = String
        var name = String
        var age  = Fixnum
      end
      EOF
    }
     
    context "(class)" do
      subject { User }
      its(:vals) { should be_kind_of ActiveSupport::OrderedHash }
      its(:vals) { should == { "key" => String } }
      its(:vars) { should be_kind_of ActiveSupport::OrderedHash }
      its(:vars) { should == { "name" => String, "age" => Fixnum } }

      describe ".build" do
        # "creates a new instance"
        its(:build) { should be_kind_of User }

        specify do
          User.build.should be_kind_of(User)
          User.build(:name=>"foo").name.should == "foo"
          User.build(:key=>"x", :name=>"foo").key.should == "x"
        end
      end
    end

    context "(instance)" do
      let(:user) { User.new }
      subject    { user}

      describe "attributes" do
        it { should respond_to(:key) }
        it { should respond_to(:name) }
        it { should respond_to(:age) }
        it { should respond_to(:[]) }
        it { should respond_to(:[]=) }
        it { should_not respond_to(:xxx) }
      end

      describe "#name=" do
        specify "accept 'maiha'" do
          (user.name = 'maiha').should == 'maiha'
        end

        specify "reject 100" do
          lambda { user.name = 100 }.should raise_error(TypeError)
        end
      end

      describe "enumerable" do
        it { should respond_to(:each) }
        it { should respond_to(:map) }
      end
    end
  end

  ######################################################################
  ### Column names

  context "(attrs)" do
    before { scala_source("A", <<-EOF)
      class A
        include Typed::Scala
        val key   = String
        var attrs = Hash
      end
      EOF
    }

    describe "#attrs, #attrs=" do
      subject { A.new }

      specify do
        a = A.new
        a.attrs = {:x=>1}
        a.attrs.should == {:x=>1}
      end
    end

    describe ".build" do
      context "()" do
        subject { A.build }
        specify { lambda { subject.key   }.should raise_error(Typed::NotDefined) }
        specify { lambda { subject.attrs }.should raise_error(Typed::NotDefined) }
      end

      context '(:key=>"x", :attrs=>{:a=>1})' do
        subject { A.build(:key=>"x", :attrs=>{:a=>1}) }
        its(:key)   { should == "x" }
        its(:attrs) { should == {:a=>1} }
      end
    end
  end

  ######################################################################
  ### Two files at same time

  context "(two files)" do
    before { scala_source("A", <<-EOF)
      class A
        include Typed::Scala
        val key = String
        var val = String
      end
      EOF
    }
     
    before { scala_source("B", <<-EOF)
      class B
        include Typed::Scala
        val key = Fixnum
        var url = String
      end
      EOF
    }

    specify "should be independent" do
      A.vals.should == { "key" => String }
      A.vars.should == { "val" => String }
      B.vals.should == { "key" => Fixnum }
      B.vars.should == { "url" => String }
    end

    specify "accessors" do
      a = A.new
      b = B.new

      a.key = "foo"
      a.val = "xyz"
      b.key = 10000
      b.url = "http"

      a.key.should == "foo"
      a.val.should == "xyz"
      a["key"].should == "foo"
      a["val"].should == "xyz"

      b.key.should == 10000
      b.url.should == "http"
      b["key"].should == 10000
      b["url"].should == "http"
    end

    context "read non defined field" do
      subject { lambda { A.new["xxx"] } }
      it { should raise_error(Typed::NotDefined) }
      it { should raise_error(/xxx is not a member of A/) }
    end

    context "read defined but not initiaized field" do
      context "[key]" do
        subject { lambda { A.new["key"] } }
        it { should raise_error(Typed::NotDefined) }
        it { should raise_error(/'key' is not initialized/) }
      end

      context "#key" do
        subject { lambda { A.new.key } }
        it { should raise_error(Typed::NotDefined) }
        it { should raise_error(/'key' is not initialized/) }
      end
    end

    context "write non defined field" do
      subject { lambda { A.new["xxx"] = 1 } }
      it { should raise_error(Typed::NotDefined) }
      it { should raise_error(/xxx is not a member of A/) }
    end

    describe "write twice" do
      context "val" do
        subject { lambda { b = B.new; b.key = 0;  b.key = 1 } }
        it { should raise_error(Typed::FixedValue) }
        it { should raise_error(/reassignment to key/) }
      end
      
      context "var" do
        subject { lambda { b = B.new; b.url = "x";  b.url = "y" } }
        it { should_not raise_error }
      end
    end
  end

  ######################################################################
  ### Inheritance

  context "(Point3D < Point2D)" do
    before { scala_source("Point2D", <<-EOF)
      class Point2D
        include Typed::Scala
        val x = Fixnum
        val y = Fixnum
      end
      EOF
    }
     
    before { scala_source("Point3D", <<-EOF)
      class Point3D < Point2D
        val z = Fixnum
      end
      EOF
    }

    context "Point2D" do
      specify "contains x,y" do
        Point2D.vals.keys.should == %w( x y )
      end

      describe "#x, #x=" do
        specify "exist" do
          p = Point2D.new
          p.x = 1
          p.x.should == 1
          lambda { p.x = 2 }.should raise_error(Typed::FixedValue)
        end
      end

      describe "#z" do
        specify "not exist" do
          p = Point2D.new
          lambda { p["z"] = 3 }.should raise_error(Typed::NotDefined)
          lambda { p.z = 3    }.should raise_error(NoMethodError)
        end
      end
    end

    context "Point3D" do
      specify "contains x,y,z" do
        Point3D.vals.keys.should == %w( x y z )
      end

      describe "#x, #x=, [x], [x]=" do
        specify "exist" do
          p = Point3D.new
          p.x = 1
          p.x.should == 1
          p["x"].should == 1
          lambda { p.x = 2    }.should raise_error(Typed::FixedValue)
          lambda { p["x"] = 2 }.should raise_error(Typed::FixedValue)
        end
      end

      describe "#z, #z=, [z], [z]=" do
        specify "exist" do
          p = Point3D.new
          p.z = 1
          p.z.should == 1
          p["z"].should == 1
          lambda { p.z = 2    }.should raise_error(Typed::FixedValue)
          lambda { p["z"] = 2 }.should raise_error(Typed::FixedValue)
        end
      end
    end
  end

  ######################################################################
  ### TODO

  describe "check method conflictions like [], []=" do
    specify do
      pending "will be implemented in version 0.3.0"
    end
  end

  context "when val or var are overridden in same context" do
    specify do
      pending "will be implemented in version 0.3.0"
    end
  end

  context "when val or var are overridden in subclass" do
    specify do
      pending "will be implemented in version 0.3.0"
    end
  end
end
