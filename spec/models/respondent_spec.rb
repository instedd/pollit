require 'spec_helper'

describe Respondent do
  it "can be instantiated" do
    Respondent.new.should be_an_instance_of(Respondent)
  end

  it "can be saved successfully" do
    Respondent.make.should be_persisted
  end
end
