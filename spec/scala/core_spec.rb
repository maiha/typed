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
end
