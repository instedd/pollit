require 'spec_helper'

describe Poll do

  context "workflow" do

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
      p = Poll.make!(:with_questions, :confirmation_words => ["Sí"])
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
      p.accept_answer("11", p.respondents.first)
      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      response = p.accept_answer("5", p.respondents.first)
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

    it "should jump to specified question after text answer" do
      p = Poll.make!(:with_text_questions)
      p.questions.first.update_attributes! next_question_definition: { 'next' => p.questions[2].id }
      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first
      p.accept_answer(p.confirmation_words.first, respondent)
      p.accept_answer('answer1', respondent).should eq(p.questions[2].message)
      respondent.reload.current_question_id.should eq(p.questions[2].id)
    end

    it "should jump to a question based on option" do
      p = Poll.make!(:with_respondents, kind: :manual, questions: [
        Question.make(:options, :options => %w(foo bar baz), :position => 1),
        Question.make(:options, :options => %w(foo bar baz), :position => 2),
        Question.make(:options, :options => %w(oof rab zab), :position => 3),
        Question.make(:options, :options => %w(oof rab zab), :position => 4)
      ])

      p.questions.first.update_attributes! next_question_definition: { 'case' => { 'foo' => p.questions[1].id, 'bar' => p.questions[2].id, 'baz' => p.questions[3].id } }
      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first
      p.accept_answer(p.confirmation_words.first, respondent)
      p.accept_answer('baz', respondent).should eq(p.questions[3].message)
      respondent.reload.current_question_id.should eq(p.questions[3].id)
    end

    it "should proceed to next question if no jump is defined for that option" do
      p = Poll.make!(:with_respondents,kind: :manual, questions: [
        Question.make(:options, :options => %w(foo bar baz), :position => 1),
        Question.make(:options, :options => %w(foo bar baz), :position => 2),
        Question.make(:options, :options => %w(oof rab zab), :position => 3),
        Question.make(:options, :options => %w(oof rab zab), :position => 4)
      ])

      p.questions.first.update_attributes! next_question_definition: { 'case' => { 'foo' => p.questions[1].id, 'bar' => p.questions[2].id } }
      p.stubs(:send_messages).returns(true)
      p.start

      respondent = p.respondents.first
      p.accept_answer(p.confirmation_words.first, respondent)
      p.accept_answer('baz', respondent).should eq(p.questions[1].message)
      respondent.reload.current_question_id.should eq(p.questions[1].id)
    end

    it "should send messages with nuntium" do
      p = Poll.make!(:with_text_questions)
      p.should_receive(:send_messages)
      p.start
    end

  end

end
