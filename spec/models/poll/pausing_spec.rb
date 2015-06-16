require 'spec_helper'

describe Poll do

  context "pausing" do

    let(:poll) do
      Poll.make!(:with_text_questions, :respondents => [
        Respondent.make!(:phone => 'sms://111'),
        Respondent.make!(:phone => 'sms://222'),
        Respondent.make!(:phone => 'sms://333'),
      ])
    end

    let (:r1) {poll.respondents.first}
    let (:r2) {poll.respondents.second}
    let (:r3) {poll.respondents.third}

    it "should not send next question if poll is paused" do
      # Poll starts and invitations are sent to both respondents
      poll.start.should be_true
      messages.should have(3).items and messages.clear

      # R1 confirms participation and is sent first question
      poll.accept_answer("yes", r1).should_not be_nil

      poll.pause

      # Confirmation from r2 arrives and r1 answers, no messages should be dispatched
      poll.accept_answer("answer to q1", r1).should be_nil
      poll.accept_answer("yes", r2).should be_nil

      r1.current_question.should eq(poll.questions.second)
      r2.current_question.should eq(poll.questions.first)
      r3.current_question.should be_nil
    end

    it "should send next questions when poll is resumed" do
      poll.start
      poll.accept_answer("yes", r1)
      poll.pause.should be_true
      messages.clear

      poll.reload

      # Confirmation from r2 arrives and r1 answers, no messages should be dispatched
      poll.accept_answer("answer to q1", r1).should be_nil
      poll.accept_answer("yes", r2).should be_nil

      r1.reload.current_question_sent.should be_false
      r2.reload.current_question_sent.should be_false

      poll.resume.should be_true

      messages.should have(2).items
      messages.sort_by! {|m| m[:to]}
      messages[0][:body].should match(/#{poll.questions.second.message}/)
      messages[1][:body].should match(/#{poll.questions.first.message}/)

      r1.reload.current_question.should eq(poll.questions.second)
      r2.reload.current_question.should eq(poll.questions.first)
      r3.reload.current_question.should be_nil

      # No new messages should be sent if paused and resumed again
      messages.clear
      poll.pause
      poll.resume
      messages.should have(0).items
    end

    it "should not resend current question when poll is resumed" do
      poll.start
      poll.accept_answer("yes", r1).should_not be_nil
      poll.accept_answer("yes", r2).should_not be_nil
      poll.accept_answer("answer to q1", r1).should_not be_nil

      messages.clear

      poll.pause.should  be_true
      poll.resume.should be_true

      messages.should have(0).items
    end

    it "should send goodbye message when poll is resumed" do
      poll.start
      poll.accept_answer("yes", r1).should_not be_nil
      poll.accept_answer("answer to q1", r1).should_not be_nil
      poll.accept_answer("answer to q2", r1).should_not be_nil

      poll.pause and messages.clear

      poll.accept_answer("answer to q3", r1).should be_nil

      poll.resume.should be_true

      messages.should have(1).items
      messages[0][:body].should eq(poll.goodbye_message)
    end

  end

end
