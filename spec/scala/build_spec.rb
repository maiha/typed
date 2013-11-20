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

    def check  ; User.check(input)   ; end
    def check! ; User.check!(input)  ; end
    def build  ; User.build(input)   ; end
    def build! ; User.build!(input)  ; end
    def apply  ; User.apply(*input)  ; end
    def apply! ; User.apply!(*input) ; end

    ######################################################################
    ### apply(array)

    describe "from array" do
      let(:input) { ["001", "aya", 12] }
      subject { apply }

      its(:key ) { should == "001" }
      its(:name) { should == "aya" }
      its(:age ) { should == 12    }

      context "(complete)" do
        specify do
          expect( apply  ).to be_a_kind_of(User)
          expect( apply! ).to be_a_kind_of(User)
        end
      end

      context "(less)" do
        before { input.pop }
        specify do
          expect( apply  ).to be_a_kind_of(User)
          expect{ apply! }.to raise_error(Typed::SizeMismatch)
        end
      end

      context "(more)" do
        before { input << "!!!" }
        specify do
          expect( apply  ).to be_a_kind_of(User)
          expect{ apply! }.to raise_error(Typed::SizeMismatch)
        end
      end
    end

    # use case
    describe ".apply!" do
      subject { User.apply!("turi", "aya", 12) }

      its(:key ) { should == "turi" }
      its(:name) { should == "aya" }
      its(:age ) { should == 12 }
    end

    ######################################################################
    ### build(hash)

    context "(complete hash)" do
      let(:input) { {:key=>"turi", :name=>"aya", :age=>12 } }

      specify do
        expect( check  ).to eq(input)
        expect( check! ).to eq(input)
        expect( build  ).to be_a_kind_of(User)
        expect( build! ).to be_a_kind_of(User)
      end
    end

    context "(less hash)" do
      let(:input) { {:name => "aya"} }

      specify do
        expect( check  ).to eq(input)
        expect{ check! }.to raise_error(Typed::SizeMismatch)
        expect( build  ).to be_a_kind_of(User)
        expect{ build! }.to raise_error(Typed::SizeMismatch)
      end
    end

    context "(more hash)" do
      let(:input) { {:key=>"turi", :name=>"aya", :age=>12, :state=>true } }

      specify do
        expect( check  ).to eq(input)
        expect{ check! }.to raise_error(Typed::SizeMismatch)
        expect( build  ).to be_a_kind_of(User)
        expect{ build! }.to raise_error(Typed::SizeMismatch)
      end
    end

    context "(no args)" do
      specify do
        expect{ User.check  }.to raise_error(ArgumentError)
        expect{ User.check! }.to raise_error(ArgumentError)
        expect{ User.build  }.to raise_error(ArgumentError)
        expect{ User.build! }.to raise_error(ArgumentError)
      end
    end

    # use case
    describe ".build!" do
      before  { @hash = {:key=>"turi", :name=>"aya", :age=>12 } }
      subject { User.build!(@hash) }

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
