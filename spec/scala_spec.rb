require "spec_helper"

describe Typed::Scala do
  before { @loaded = [] }
  after { @loaded.each{|klass| Object.__send__(:remove_const, klass) if Object.const_defined?(klass) } }
      
  def source(klass, code)
    path = tmp_path("scala/inline.rb")
    path.parent.mkpath
    path.open("w+"){|f| f.puts(code) }
    load(path.to_s)
    @loaded << klass
  end

  describe "User" do
    before { source("User", <<-EOF)
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
      it { should respond_to(:[]) }
      it { should respond_to(:[]=) }

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

  context "(two files)" do
    before { source("A", <<-EOF)
      class A
        include Typed::Scala
        val key = String
        var val = String
      end
      EOF
    }
     
    before { source("B", <<-EOF)
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

