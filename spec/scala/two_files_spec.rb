require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

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
end
