require 'spec_helper'

describe Poll do
  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make.should be_persisted
  end
end