require 'spec_helper'

describe Poll do

  context "non recurrences" do
    it "should have nil occurrence" do
      poll = Poll.make! :respondents => [ Respondent.make! ]

      poll.start
      poll.current_occurrence.should be_nil
      poll.pause
      poll.current_occurrence.should be_nil
      poll.resume
    end
  end

  context "recurrences" do
    it "should not have recurrences by default" do
      Poll.make!.recurrence_kind.should eq(:none)
    end

    it "should be serialized" do
      poll = Poll.find(Poll.make!.id)
      poll.recurrence_kind.should eq(:none)
    end

    it "should save from params" do
      poll = Poll.make!
      poll.update_attributes! 'recurrence_rule' => weekly_json(1, 2)
      poll = Poll.find(poll.id)
      poll.recurrence_kind.should eq(:iterative)
      days_of_weekly_rule(poll.recurrence).should eq([1,2])
    end

    it "should send invites on first scheduled date" do
      stub_time "Apr 14 2014 10:00" # monday

      poll = Poll.make! recurrence_rule: weekly_json(:tuesday),
        :respondents => [
          r1 = Respondent.make!(:phone => 'sms://111')
        ]

      poll.start
      messages.should be_empty

      stub_time "Apr 15 2014 12:00" # tuesday
      messages.should_not be_empty

      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(poll.welcome_message)
    end

    it "should receive first question upon iteration" do
      stub_time "Apr 14 2014 10:00" # monday

      poll = Poll.make! recurrence_rule: weekly_json(:tuesday),
        :respondents => [
          r1 = Respondent.make!(:phone => 'sms://111')
        ],
        :questions => [Question.make!, Question.make!]
      q1 = poll.questions.first
      q2 = poll.questions.second

      poll.start

      stub_time "Apr 15 2014 12:00" # tuesday
      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(poll.welcome_message)

      poll.accept_answer(poll.confirmation_words.first, r1).should eq(q1.message)
      poll.accept_answer("answer to q1", r1).should eq(q2.message)

      messages.clear

      stub_time "Apr 17 2014 12:00"
      messages.should be_empty

      stub_time "Apr 22 2014 12:00" # tuesday again!
      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(q1.message)
      r1.reload

      poll.accept_answer("answer to q1", r1).should eq(q2.message)
    end

    it "should restart poll on resume and wait till next iteration" do
      stub_time "Apr 14 2014 10:00" # monday

      poll = Poll.make! recurrence_rule: weekly_json(:tuesday),
        :respondents => [
          r1 = Respondent.make!(:phone => 'sms://111')
        ],
        :questions => [Question.make!, Question.make!]
      q1 = poll.questions.first
      q2 = poll.questions.second

      poll.start

      stub_time "Apr 15 2014 12:00" # tuesday
      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(poll.welcome_message)

      poll.accept_answer(poll.confirmation_words.first, r1).should eq(q1.message)
      poll.accept_answer("answer to q1", r1).should eq(q2.message)

      messages.clear

      poll.pause

      stub_time "Apr 22 2014 12:00" # tuesday again!
      messages.should be_empty

      stub_time "Apr 25 2014 12:00" # friday
      poll.resume
      messages.should be_empty

      stub_time "Apr 29 2014 12:00" # tuesday again!
      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(q1.message)
      r1.reload

      poll.accept_answer("answer to q1", r1).should eq(q2.message)
    end

    it "should store current occurrence" do
      stub_time "Apr 14 2014 10:00" # monday

      poll = Poll.make! recurrence_rule: weekly_json(:tuesday),
        :respondents => [ Respondent.make! ]

      poll.start

      stub_time "Apr 15 2014 12:00", poll

      poll.current_occurrence.should eq(Time.parse("Apr 15 2014 10:00"))
    end

    it "should store answers per occurrence" do
      stub_time "Apr 14 2014 10:00" # monday

      poll = Poll.make! recurrence_rule: weekly_json(:tuesday),
        :respondents => [ r1 = Respondent.make! ],
        :questions => [ Question.make!, Question.make!]
      q1 = poll.questions.first
      q2 = poll.questions.second

      poll.start
      stub_time "Apr 15 2014 12:00", poll, r1

      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(poll.welcome_message)

      poll.accept_answer(poll.confirmation_words.first, r1).should eq(q1.message)
      poll.accept_answer("answer for q1 o1", r1).should eq(q2.message)
      poll.accept_answer("answer for q2 o1", r1).should eq(poll.goodbye_message)

      messages.clear
      stub_time "Apr 22 2014 12:00", poll, r1
      messages[0][:to].should eq(r1.phone)
      messages[0][:body].should eq(q1.message)

      poll.accept_answer("answer for q1 o2", r1).should eq(q2.message)
      poll.accept_answer("answer for q2 o2", r1).should eq(poll.goodbye_message)

      poll.answers[0].response.should eq("answer for q1 o1")
      poll.answers[0].occurrence.should eq(Time.parse("Apr 15 2014 10:00"))
      poll.answers[1].response.should eq("answer for q2 o1")
      poll.answers[1].occurrence.should eq(Time.parse("Apr 15 2014 10:00"))
      poll.answers[2].response.should eq("answer for q1 o2")
      poll.answers[2].occurrence.should eq(Time.parse("Apr 22 2014 10:00"))
      poll.answers[3].response.should eq("answer for q2 o2")
      poll.answers[3].occurrence.should eq(Time.parse("Apr 22 2014 10:00"))
    end
  end

end
