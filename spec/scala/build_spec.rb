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

    subject { User }
     
    its(:vals) { should be_kind_of ActiveSupport::OrderedHash }
    its(:vals) { should == { "key" => String } }
    its(:vars) { should be_kind_of ActiveSupport::OrderedHash }
    its(:vars) { should == { "name" => String, "age" => Fixnum } }

    describe ".apply" do
      specify "less args" do
        user = User.apply("001", "aya")
        user.key .should == "001"
        user.name.should == "aya"
        lambda { user.age}.should raise_error(Typed::NotDefined)
      end

      specify "exact args" do
        user = User.apply("001", "aya", 12)
        user.key .should == "001"
        user.name.should == "aya"
        user.age .should == 12
      end

      specify "more args" do
        lambda { User.apply("001", "aya", 12, "!") }.should raise_error(/expect 3 args/)
      end
    end

    describe ".apply!" do
      specify "less args" do
        lambda { User.apply!("001", "aya") }.should raise_error(/expect 3 args/)
      end

      specify "exact args" do
        user = User.apply!("001", "aya", 12)
        user.key .should == "001"
        user.name.should == "aya"
        user.age .should == 12
      end

      specify "more args" do
          lambda { User.apply!("001", "aya", 12, "!") }.should raise_error(/expect 3 args/)
      end
    end

    describe ".build" do
      # "creates a new instance"
      its(:build) { should be_kind_of User }

      specify "ok" do
        User.build.should be_kind_of(User)
        User.build(:name=>"foo").name.should == "foo"

        user = User.build(:key=>"x", :age=>12)
        user.key.should == "x"
        user.age.should == 12
      end

      specify "not member" do
        lambda { User.build(:foo => "!") }.should raise_error(Typed::NotDefined)
      end

      specify "type error" do
        lambda { User.build(:age => "!") }.should raise_error(TypeError)
      end
    end
  end
end
