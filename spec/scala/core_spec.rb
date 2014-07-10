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
        maybe var email = String
      end
      EOF
    }
     
    let(:user) { User.new }
    subject    { user}

    describe ".variables" do
      subject { User.variables }
      its(:keys) { should == %w( key name age email) }
      its(["key" ]) { should == String }
      its(["name"]) { should == String }
      its(["age" ]) { should == Fixnum }
      its(["email"]) { should == String }

      specify "#each_pair" do
        hash = {}
        subject.each_pair do |name, type|
          hash[name] = type
        end
        hash.should == {
          "key"   => String,
          "name"  => String,
          "age"   => Fixnum,
          "email" => String
        }
      end
    end

    describe "attributes" do
      it { should respond_to(:key) }
      it { should respond_to(:name) }
      it { should respond_to(:age) }
      it { should respond_to(:email) }
      it { should respond_to(:[]) }
      it { should respond_to(:[]=) }
      it { should_not respond_to(:xxx) }
    end

    describe "#name=" do
      specify "accept 'maiha'" do
        (user.name = 'maiha').should == 'maiha'
      end

      specify "reject nil" do
        lambda { user.name = nil }.should raise_error(TypeError)
      end

      specify "reject 100" do
        lambda { user.name = 100 }.should raise_error(TypeError)
      end

    end

    describe "#email=" do
      specify "accept 'foo@bar'" do
        (user.email = 'foo@bar').should == 'foo@bar'
      end

      specify 'accept nil' do
        (user.email = nil).should == nil
      end

      specify 'reject 100' do
        lambda { user.email = 100 }.should raise_error(TypeError)
      end
   end

    describe "enumerable" do
      it { should respond_to(:each) }
      it { should respond_to(:map) }
    end

    describe "attributes" do
      subject { User.attrs(User.apply!("001", "aya", 12, nil)) }

      its(:class ) { should == Hash }
      its(:size  ) { should == 4 }
      its(:keys  ) { should == %w( key name age email ) }
      its(:values) { should == ["001", "aya", 12, nil] }
    end
  end
end
