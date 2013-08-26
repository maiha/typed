require "spec_helper"

describe Typed::Scala do
  before { write_and_load(source) }

  let(:source) { commented_source.gsub(/^\s*#/m, '') }
  let(:user)   { User.new }
  subject      { user}

  def write_and_load(code)
    path = tmp_path("scala/inline.rb")
    path.parent.mkpath
    path.open("w+"){|f| f.puts(code) }
    load(path.to_s)
  end

  context "User" do
    # comment outed for the editor issues
    let(:commented_source) { <<-EOF
      # class User
      #   include Typed::Scala
      # 
      #   var name = String
      #   var age  = Fixnum
      # end
      EOF
    }

    it { should respond_to(:name) }
    it { should respond_to(:age) }
    it { should_not respond_to(:xxx) }

    describe "#types" do
      its(:types) { should == {
          "age"  => Fixnum,
          "name" => String,
        } }
    end

    describe ".types" do
      specify "same as User#type" do
        user.types.should == User.types
      end
    end

    describe "#name=" do
      specify "accept 'maiha'" do
        (user.name = 'maiha').should == 'maiha'
      end

      specify "reject 100" do
        lambda { user.name = 100 }.should raise_error(TypeError)
      end
    end
  end
end
