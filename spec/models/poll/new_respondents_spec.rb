require 'spec_helper'

describe Poll do

  context "new respondents" do
    let(:poll) do
      Poll.make!(:with_text_questions, :respondents => [
        Respondent.make!(:phone => 'sms://111'),
        Respondent.make!(:phone => 'sms://222'),
      ])
    end

    let (:r1) {poll.respondents.first}
    let (:r2) {poll.respondents.second}

    let (:r3) {Respondent.make!(:phone => 'sms://333')}
    let (:r4) {Respondent.make!(:phone => 'sms://444')}

    it "should not invite users right away if poll is configuring" do
      poll.status_configuring?.should be_true
      poll.expects(:invite_new_respondents).never

      poll.on_respondents_added
    end

    it "should not invite users right away if poll is paused" do
      poll.start
      poll.pause
      poll.status_paused?.should be_true
      poll.expects(:invite_new_respondents).never

      poll.on_respondents_added
    end

    it "should send invite after resuming to respondents added while paused" do
      poll.start
      messages.clear
      poll.pause

      # We add r3 and r4 to the poll and resume it
      poll.respondents << r3 << r4
      poll.resume

      messages.should have(2).items
      messages.sort_by! {|m| m[:to]}
      messages[0][:to].should eq(r3.phone)
      messages[1][:to].should eq(r4.phone)
      messages[0][:body].should eq(poll.welcome_message)
      messages[1][:body].should eq(poll.welcome_message)
    end

    it "should sent invite right away if poll is running" do
      poll.start
      messages.clear

      poll.respondents << r3
      poll.on_respondents_added

      messages.should have(1).items
      messages[0][:to].should eq(r3.phone)
      messages[0][:body].should eq(poll.welcome_message)

      messages.clear

      poll.respondents << r4
      poll.on_respondents_added

      messages.should have(1).items
      messages[0][:to].should eq(r4.phone)
      messages[0][:body].should eq(poll.welcome_message)
    end
  end

end
