require "spec_helper"

describe Typed::Scala do
  include_context "scala_source"

  ######################################################################
  ### Basic usage

  describe "Kvs" do
    before { scala_source("Kvs", <<-EOF)
      class Kvs
        include Typed::Scala

        val key = String
        var val = String
      end
      EOF
    }

    describe "#==" do
      context "(different class)" do
        specify do
          Kvs.new.should_not == Kvs
          Kvs.new.should_not == {}
          Kvs.new.should_not == []
        end
      end

      context "(blank)" do
        specify do
          Kvs.new.should == Kvs.new
        end
      end
      
      context "(full data)" do
        specify do
          Kvs.apply("x", "1").should     == Kvs.apply("x", "1")
          Kvs.apply("x", "1").should_not == Kvs.apply("x", "2")
        end
      end

      context "less data" do
        specify do
          Kvs.apply("x", "1").should_not == Kvs.apply("x")
          Kvs.apply("x", "1").should_not == Kvs.new
        end
      end
    end
  end
end
