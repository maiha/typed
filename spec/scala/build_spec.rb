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
        lambda { User.apply("001", "aya", 12, "!") }.should raise_error(/expects 3 args/)
      end
    end

    describe ".apply!" do
      specify "less args" do
        lambda { User.apply!("001", "aya") }.should raise_error(/expects 3 args/)
      end

      specify "exact args" do
        user = User.apply!("001", "aya", 12)
        user.key .should == "001"
        user.name.should == "aya"
        user.age .should == 12
      end

      specify "more args" do
          lambda { User.apply!("001", "aya", 12, "!") }.should raise_error(/expects 3 args/)
      end
    end

    describe ".check" do
      before  { @hash = {:key=>"turi", :name=>"aya", :age=>12 } }
      subject { User.check(@hash) }

      specify "(valid hash) return given hash itself" do
        expect( subject ).to eq @hash
      end

      specify "(invalid hash) raise errors" do
        @hash.clear
        expect { subject }.to raise_error(Typed::SizeMismatch)
      end
    end


    describe ".build" do
      specify "(no args) raise ArgumentError" do
        expect { User.build }.to raise_error(ArgumentError)
      end

      specify "(non hash args) raise ArgumentError" do
        expect { User.build([]) }.to raise_error(ArgumentError)
      end

      context "(hash)" do
        before  { @hash = {:key=>"turi", :name=>"aya", :age=>12 } }
        subject { User.build(@hash) }

        its(:key ) { should == "turi" }
        its(:name) { should == "aya" }
        its(:age ) { should == 12 }

        specify "when less args, raise Typed::SizeMismatch" do
          @hash.delete(:age)
          expect { subject }.to raise_error(Typed::SizeMismatch)
          expect { subject }.to raise_error(/age/)
        end

        specify "when more args, raise Typed::SizeMismatch" do
          @hash[:extra] = 10
          expect { subject }.to raise_error(Typed::SizeMismatch)
          expect { subject }.to raise_error(/extra/)
        end

        specify "when unknown field, raise Typed::NotDefined" do
          @hash.delete(:age)
          @hash[:xxx] = 100
          expect { subject }.to raise_error(Typed::NotDefined)
        end

        specify "when type mismatch, raise TypeError" do
          @hash[:age] = "!"
          expect { subject }.to raise_error(TypeError)
        end
      end
    end
  end
end
