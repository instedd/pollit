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

  context "as message" do
    it "can be set to message being text" do
      Question.make(:text, :title => "A question?").to_message.should\
        eq("A question?")
    end

    it "can be set to message being options" do
      Question.make(:options, :title => "An options question?", :options => %w(foo bar baz)).to_message.should\
        eq("An options question? a-foo b-bar c-baz")
    end

    it "can be set to message being numeric" do
      Question.make(:numeric, :title => "A numeric question?", :numeric_min => 1, :numeric_max => 4).to_message.should\
        eq("A numeric question? 1-4")
    end
  end
end