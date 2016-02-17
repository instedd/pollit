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

    it "should send next question if option response is valid (with keys)" do
      p = Poll.make!(:with_option_questions)

      q = p.questions[0]
      q.keys = %w(xy yz zx)
      q.save!

      p.reload

      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      reply = p.accept_answer("lalala", p.respondents.first)
      reply.should include("foo|bar|baz")

      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      p.respondents.first.answers.count.should eq(0)
      p.accept_answer("yz", p.respondents.first)
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
      p.questions.first.update_attributes! next_question_definition: { 'next' => p.questions[2].position }
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

      p.questions.first.update_attributes! next_question_definition: { 'case' => { 'foo' => p.questions[1].position, 'bar' => p.questions[2].position, 'baz' => p.questions[3].position } }
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

      p.questions.first.update_attributes! next_question_definition: { 'case' => { 'foo' => p.questions[1].position, 'bar' => p.questions[2].position } }
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

    describe "numeric conditions" do
      let!(:poll) do
        p = Poll.make!(questions: [
          Question.make(:numeric, :position => 1, :numeric_min => 1, :numeric_max => 100, :next_question_definition => {'cases' => [
              {'min' => 1, 'max' => 3, 'next' => 3},
              {'min' => 4, 'max' => 10, 'next' => 4},
              {'min' => 11, 'max' => 20},
              {'min' => 21, 'max' => 50, 'next' => 'end'},
            ], 'next' => 6}),
          Question.make(:numeric, title: "foo2", :position => 2),
          Question.make(:numeric, title: "foo3", :position => 3),
          Question.make(:numeric, title: "foo4", :position => 4),
          Question.make(:numeric, title: "foo5", :position => 5),
          Question.make(:numeric, title: "foo6", :position => 6),
        ], respondents: [Respondent.make])
        p.stubs(:send_messages).returns(true)
        p.start

        # To confirm joining the poll
        p.accept_answer("yes", p.respondents.first)

        p
      end
      let!(:respondent) { poll.respondents.first }

      it "branches off conditionally in numeric (1)" do
        poll.accept_answer("2", respondent).should include("foo3")
      end

      it "branches off conditionally in numeric (2)" do
        poll.accept_answer("4", respondent).should include("foo4")
      end

      it "branches off conditionally in numeric (3)" do
        poll.accept_answer("12", respondent).should eq(_("Thank you for your answers!"))
      end

      it "branches off conditionally in numeric (4)" do
        poll.accept_answer("22", respondent).should eq(_("Thank you for your answers!"))
      end

      it "branches off conditionally in numeric (5)" do
        poll.accept_answer("51", respondent).should include("foo6")
      end
    end

    context "validations" do
      def assert_validation
        p = Poll.make!(:with_questions)
        given_answer, expected_reply = yield p
        p.start

        # To confirm joining the poll
        p.accept_answer("yes", p.respondents.first)

        # The test answer
        response = p.accept_answer(given_answer, p.respondents.first)
        response.should eq(expected_reply)
      end

      describe "text" do
        it "validates text answer" do
          assert_validation do |poll|
            ["", _("Your answer was not understood.") + " " + _("Please answer with a non empty response.")]
          end
        end

        it "validates text answer with custom validation message when empty" do
          assert_validation do |poll|
            q = poll.questions.first
            q.custom_messages = {
              "empty" => "Must not be empty!",
            }
            q.save!

            ["", q.custom_messages["empty"]]
          end
        end

        it "validates text answer with custom validation message when less than min length" do
          assert_validation do |poll|
            q = poll.questions.first
            q.min_length = 5
            q.custom_messages = {
              "invalid_length" => "Invalid length!",
            }
            q.save!

            ["1", q.custom_messages["invalid_length"]]
          end
        end

        it "validates text answer with custom validation message when more than max length" do
          assert_validation do |poll|
            q = poll.questions.first
            q.max_length = 5
            q.custom_messages = {
              "invalid_length" => "Invalid length!",
            }
            q.save!

            ["123456", q.custom_messages["invalid_length"]]
          end
        end

        it "validates text answer with custom validation message when outside min max length" do
          assert_validation do |poll|
            q = poll.questions.first
            q.min_length = 4
            q.max_length = 5
            q.custom_messages = {
              "invalid_length" => "Invalid length!",
            }
            q.save!

            ["1", q.custom_messages["invalid_length"]]
          end
        end

        it "validates text answer with custom validation message when doesn't contain text" do
          assert_validation do |poll|
            q = poll.questions.first
            q.must_contain = "foo"
            q.custom_messages = {
              "doesnt_contain" => "Doesn't contain!",
            }
            q.save!

            ["this has a bar", q.custom_messages["doesnt_contain"]]
          end
        end
      end

      describe "numeric" do
        it "validates numeric answer with custom validation message when not a number" do
          assert_validation do |poll|
            3.times { poll.questions.first.destroy }
            q = poll.questions.first
            q.custom_messages = {
              "not_a_number" => "Not a number!",
            }
            q.save!

            ["hello", q.custom_messages["not_a_number"]]
          end
        end

        it "validates numeric answer with custom validation message when less than min" do
          assert_validation do |poll|
            3.times { poll.questions.first.destroy }
            q = poll.questions.first
            q.numeric_min = 10
            q.numeric_max = nil
            q.custom_messages = {
              "number_not_in_range" => "Not in range!",
            }
            q.save!

            ["9", q.custom_messages["number_not_in_range"]]
          end
        end

        it "validates numeric answer with custom validation message when greater than max" do
          assert_validation do |poll|
            3.times { poll.questions.first.destroy }
            q = poll.questions.first
            q.numeric_min = nil
            q.numeric_max = 10
            q.custom_messages = {
              "number_not_in_range" => "Not in range!",
            }
            q.save!

            ["11", q.custom_messages["number_not_in_range"]]
          end
        end

        it "validates numeric answer with custom validation message when outside range" do
          assert_validation do |poll|
            3.times { poll.questions.first.destroy }
            q = poll.questions.first
            q.numeric_min = 9
            q.numeric_max = 10
            q.custom_messages = {
              "number_not_in_range" => "Not in range!",
            }
            q.save!

            ["8", q.custom_messages["number_not_in_range"]]
          end
        end
      end

      describe "options" do
        it "validates optios answer with custom validation message when not a valid option" do
          assert_validation do |poll|
            poll.questions.first.destroy
            q = poll.questions.first
            q.custom_messages = {
              "not_an_option" => "Not an option!",
            }
            q.save!

            ["qux", q.custom_messages["not_an_option"]]
          end
        end
      end
    end
  end
end
