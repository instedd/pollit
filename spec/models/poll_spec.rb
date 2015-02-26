# encoding: UTF-8
# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'

describe Poll do
  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make!.should be_persisted
  end

  it "has an owner" do
    Poll.make!.owner.should_not be_nil
  end

  context "validations" do
    it "must have a title" do
      Poll.make(:title => "").should be_invalid
    end

    it "must require questions if specified" do
      Poll.make(:questions => []).should be_invalid
    end

    it "cannot have more than one question that collects respondent phone" do
      Poll.make(:questions => [
        Question.make(:text, collects_respondent: true),
        Question.make(:text, collects_respondent: true)
      ]).should be_invalid
    end
  end

  context "parsing google form" do
    let(:poll) do
      url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
      stub_request(:get, url).to_return_file('google-form.html')
      Poll.parse_form "http://#{url}"
    end

    let(:invalid_poll) do
      url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=INVALID'
      stub_request(:get, url).to_return_file('google-form-invalid.html')
      Poll.parse_form "http://#{url}"
    end

    def should_parse_question(name, index, kind, opts)
      question = poll.questions[index]
      question.title.should eq(opts[:title] || "Test #{name}")
      question.description.should eq(opts[:description] || "Description #{index+1}")
      question.kind.should eq(kind)
      question.field_name.should eq(opts[:field]) if opts[:field]
      question
    end

    def self.it_can_parse_question_as_text(name, index, opts={})
      it "can parse #{name} as text" do
        question = should_parse_question(name, index, :text, opts)
      end
    end

    def self.it_can_parse_question_as_options(name, index, opts={})
      it "can parse #{name} as options" do
        question = should_parse_question(name, index, :options, opts)
        opts[:options] = (0...(opts[:options_count])).map {|i| "Opt#{i+1}"} unless opts[:options]
        question.options.should eq(opts[:options])
      end
    end

    def self.it_can_parse_question_as_numeric(name, index, opts={})
      it "can parse #{name} as numeric" do
        question = should_parse_question(name, index, :numeric, opts)
        question.numeric_max.should eq(opts[:max])
        question.numeric_min.should eq(opts[:min])
      end
    end

    it "can parse public google form" do
      poll.title.should eq('Test Form')
      poll.description.should eq('The description of the form')
      poll.post_url.should eq('https://docs.google.com/spreadsheet/formResponse?formkey=FORMKEY&ifq')
      poll.questions.length.should eq(6)
    end

    it "can parse public google form with unsupported questions" do
      invalid_poll.questions.length.should eq(3)
      q = invalid_poll.questions[0]
      q.title.should eq('Grid Question')
      q.kind.should eq(:unsupported)
      q = invalid_poll.questions[2]
      q.title.should eq('Checkboxes Question')
      q.kind.should eq(:unsupported)
    end

    it_can_parse_question_as_text "text question", 0, :field => 'entry.0.single'
    it_can_parse_question_as_text "paragraph question", 1, :field => 'entry.2.single'

    it_can_parse_question_as_options "choose from list question", 2, :options_count => 3, :field => 'entry.1.single'
    it_can_parse_question_as_options "choice question", 3, :options_count => 2, :field => 'entry.5.group'
    it_can_parse_question_as_options "choice question with other", 4, :options_count => 2, :field => 'entry.6.group'

    it_can_parse_question_as_numeric "scale question", 5, :max => 5, :min => 1, :field => 'entry.7.group'

  end

  context "workflow" do

    def messages
      @nuntium_ao_messages
    end

    it "should change status to started when a poll is started" do
      poll = Poll.make!(:with_questions)
      poll.stubs(:send_messages).returns(true)

      starting = poll.start

      poll.status.should eq(:started)
    end

    it "should not set next question if confirmation word is not correct" do
      p = Poll.make!(:with_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("no", p.respondents.first)
      p.respondents.first.confirmed.should be_false
    end

    it "should set next question if confirmation word is correct" do
      p = Poll.make!(:with_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      response = p.accept_answer("yes", p.respondents.first)
      p.respondents.first.confirmed.should be_true
      p.respondents.first.current_question_id.should eq(p.questions.first.id)
      response.should eq(p.questions.first.message)
    end

    it "should set next question if confirmation word is similar" do
      p = Poll.make!(:with_questions, :confirmation_word => "Sí")
      p.stubs(:send_messages).returns(true)
      p.start

      response = p.accept_answer("si", p.respondents.first)
      p.respondents.first.confirmed.should be_true
      p.respondents.first.current_question_id.should eq(p.questions.first.id)
      response.should eq(p.questions.first.message)
    end

    it "should send next question if answer response is valid" do
      p = Poll.make!(:with_text_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      response = p.accept_answer("lalala", p.respondents.first)

      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)
    end

    it "should notify hub when answer is received" do
      p = Poll.make!(:with_text_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      r = p.respondents.first
      p.accept_answer("yes", r)

      expect { p.accept_answer("lalala", r) }.to change(Delayed::Job, :count).by(1)
      YAML.load(Delayed::Job.first.handler).answer_id.should eq(r.reload.answers.last.id)
    end

    it "should send next question if option response is valid" do
      p = Poll.make!(:with_option_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      p.accept_answer("lalala", p.respondents.first)
      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      p.respondents.first.answers.count.should eq(0)
      p.accept_answer("foo", p.respondents.first)
      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)
      p.respondents.first.answers.count.should_not eq(0)
    end

    it "should send next question if the numeric answer is valid" do
      p = Poll.make!(:with_numeric_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      p.accept_answer(11, p.respondents.first)
      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      p.accept_answer(5, p.respondents.first)
      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)
    end

    it "should skip first question used for collecting respondent phone" do
      p = Poll.make!(:with_collecting_respondent_question, questions: [
        Question.make(:field_name => 'entry.0.single', :position => 1, :title => "Question 1?", :collects_respondent => true),
        Question.make(:field_name => 'entry.1.single', :position => 2, :title => "Question 2?"),
        Question.make(:field_name => 'entry.2.single', :position => 3, :title => "Question 3?")
      ])

      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first

      p.accept_answer("yes", respondent).should eq(p.questions[1].message)
      respondent.current_question_id.should eq(p.questions[1].id)

      p.accept_answer("answer1", respondent).should eq(p.questions[2].message)
      respondent.current_question_id.should eq(p.questions[2].id)

      p.accept_answer("answer3", respondent).should eq(p.goodbye_message)
      respondent.current_question_id.should be_nil
    end

    it "should skip middle question used for collecting respondent phone" do
      p = Poll.make!(:with_collecting_respondent_question)
      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first

      p.accept_answer("yes", respondent).should eq(p.questions[0].message)
      respondent.current_question_id.should eq(p.questions[0].id)

      p.accept_answer("answer2", respondent).should eq(p.questions[2].message)
      respondent.current_question_id.should eq(p.questions[2].id)

      p.accept_answer("answer3", respondent).should eq(p.goodbye_message)
      respondent.current_question_id.should be_nil
    end

    it "should skip last question used for collecting respondent phone" do
      p = Poll.make!(:with_collecting_respondent_question, questions: [
        Question.make(:field_name => 'entry.0.single', :position => 1, :title => "Question 1?"),
        Question.make(:field_name => 'entry.1.single', :position => 2, :title => "Question 2?"),
        Question.make(:field_name => 'entry.2.single', :position => 3, :title => "Question 3?", :collects_respondent => true)
      ])

      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first

      p.accept_answer("yes", respondent).should eq(p.questions[0].message)
      respondent.current_question_id.should eq(p.questions[0].id)

      p.accept_answer("answer1", respondent).should eq(p.questions[1].message)
      respondent.current_question_id.should eq(p.questions[1].id)

      p.accept_answer("answer2", respondent).should eq(p.goodbye_message)
      respondent.current_question_id.should be_nil
    end

    it "should send messages with nuntium" do
      p = Poll.make!(:with_text_questions)
      p.should_receive(:send_messages)
      p.start
    end

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

        poll.accept_answer(poll.confirmation_word, r1).should eq(q1.message)
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

        poll.accept_answer(poll.confirmation_word, r1).should eq(q1.message)
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

        poll.accept_answer(poll.confirmation_word, r1).should eq(q1.message)
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
end
