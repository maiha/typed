require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

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
end
