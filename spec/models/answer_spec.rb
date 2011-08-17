require 'spec_helper'

describe Answer do
  it "can be instantiated" do
    Answer.new.should be_an_instance_of(Answer)
  end

  it "can be saved successfully" do
    Answer.make.should be_persisted
  end

  it "must be unique for question and respondent" do
    respondent = Respondent.make
    question = Question.make

    Answer.make(:respondent => respondent, :question => question).should be_persisted
    Answer.make_unsaved(:respondent => respondent, :question => question).should be_invalid
  end

end
