require "spec_helper"

describe Typed::Scala do
  before { write_and_load(source) }

  let(:source) { commented_source.gsub(/^\s*#/m, '') }

  def write_and_load(code)
    Object.__send__(:remove_const, "User") if Object.const_defined?("User")
    path = tmp_path("scala/inline.rb")
    path.parent.mkpath
    path.open("w+"){|f| f.puts(code) }
    load(path.to_s)
  end

  describe "User" do
    # comment outed for the editor issues
    let(:commented_source) { <<-EOF
      # class User
      #   include Typed::Scala
      # 
      #   val key  = String
      #   var name = String
      #   var age  = Fixnum
      # end
      EOF
    }

    context "(class)" do
      subject { User }
      its(:vals) { should == { "key" => String } }
      its(:vars) { should == { "name" => String, "age" => Fixnum } }
    end

    context "(instance)" do
      let(:user) { User.new }
      subject    { user}

      it { should respond_to(:key) }
      it { should respond_to(:name) }
      it { should respond_to(:age) }
      it { should_not respond_to(:xxx) }
      it { should respond_to(:attrs) }

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
end

