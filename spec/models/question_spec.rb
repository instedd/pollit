require 'spec_helper'

describe Question do
  it "can be instantiated" do
    Question.new.should be_an_instance_of(Question)
  end

  it "can be saved successfully" do
    Question.make.should be_persisted
  end

  it "can be saved successfully with options" do
    question = Question.make(:options)
    question.should be_persisted
    question.options.should_not be_empty
  end

  it "belongs to a poll" do
    Question.make.poll.should_not be_nil
  end
end