require "spec_helper"

describe Typed::Events do
  it "should observe :read event" do
    data = Typed::Hash.new
    data[:a] = 1
    data[:b] = 2

    read = []
    data.events.on(:read) {|k,v|
      read << [k,v]
    }

    data[:a]

    read.should == [[:a,1]]
  end

  it "should observe :write event" do
    data = Typed::Hash.new
    data[:a] = 1
    data[:b] = 2

    written = []
    data.events.on(:write) {|k,v|
      written << [k,v]
    }

    data[:a] = 3
    data[:c] = 5
    written.should == [[:a,3], [:c,5]]
  end

  it "should not fire :read event on :write" do
    data = Typed::Hash.new

    read = []
    data.events.on(:read) {|k,v|
      read << [k,v]
    }

    data[:x] = 10
    read.should == []
  end
end

