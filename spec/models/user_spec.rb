require 'spec_helper'

describe User do
  it "can be instantiated" do
    User.new.should be_an_instance_of(User)
  end

  it "can be saved successfully" do
    User.make.should be_persisted
  end

  it "has many polls" do
    user = User.make
    3.times do Poll.make(:owner => user) end
    user.reload.should have(3).polls
  end

end