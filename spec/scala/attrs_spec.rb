require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

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

    describe ".build!" do
      context '(:key=>"x", :attrs=>{:a=>1})' do
        subject { A.build!(:key=>"x", :attrs=>{:a=>1}) }
        its(:key)   { should == "x" }
        its(:attrs) { should == {:a=>1} }
      end
    end
  end
end
