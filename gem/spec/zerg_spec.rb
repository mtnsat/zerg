require 'zerg'

describe Zerg::Hive do
  it "doesnt load hive" do
    Zerg::Hive.load("blah").should eql("nothing")
  end

  it "doesnt verify hive" do
    Zerg::Hive.verify("blah").should eql("nothing")
  end
end