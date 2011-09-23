require 'spec_helper'

describe Poll do
  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make.should be_persisted
  end

  it "has an owner" do
    Poll.make.owner.should_not be_nil
  end

  context "validations" do
    it "must have a title" do
      Poll.make_unsaved(:title => "").should be_invalid
    end

    it "must require questions if specified" do
      Poll.make_unsaved(:questions => []).should be_invalid
    end
  end

  context "parsing google form" do
    let(:poll) do
      url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
      stub_request(:get, url).to_return_file('google-form.html')
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

    it "should change status to started when a poll is started" do
      poll = Poll.make(:with_questions)
      poll.stubs(:send_messages).returns(true)
      
      starting = poll.start
      
      poll.status.should eq(:started)
    end

    it "should not set next question if confirmation word is not correct" do
      p = Poll.make(:with_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("lala", p.respondents.first)
      p.respondents.first.confirmed.should be_false
    end

    it "should set next question if confirmation word is correct" do
      p = Poll.make(:with_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      response = p.accept_answer("yes", p.respondents.first)
      p.respondents.first.confirmed.should be_true
      p.respondents.first.current_question_id.should eq(p.questions.first.id)
      response.should eq(p.questions.first.message)
    end

    it "should send next question if the option is valid" do
      p = Poll.make(:with_text_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      response = p.accept_answer("lalala", p.respondents.first)

      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)

      p = Poll.make(:with_option_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      p.accept_answer("lalala", p.respondents.first)
      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      p.respondents.first.answers.count.should eq(0)
      p.accept_answer("foo", p.respondents.first)
      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)
      p.respondents.first.answers.count.should_not eq(0)

      p = Poll.make(:with_numeric_questions)
      p.stubs(:send_messages).returns(true)
      p.start

      p.accept_answer("yes", p.respondents.first)
      p.accept_answer(11, p.respondents.first)
      p.respondents.first.current_question_id.should_not eq(p.questions.first.lower_item.id)
      p.accept_answer(5, p.respondents.first)
      p.respondents.first.current_question_id.should eq(p.questions.first.lower_item.id)
    end

    it "should send messages with nuntium" do
      p = Poll.make(:with_text_questions)
      p.should_receive(:send_messages)
      p.start
    end

    it_can_parse_question_as_text "text question", 0, :field => 'entry.0.single'
    it_can_parse_question_as_text "paragraph question", 1, :field => 'entry.2.single'
    
    it_can_parse_question_as_options "choose from list question", 2, :options_count => 3, :field => 'entry.1.single'
    it_can_parse_question_as_options "choice question", 3, :options_count => 2, :field => 'entry.5.group'
    it_can_parse_question_as_options "choice question with other", 4, :options_count => 2, :field => 'entry.6.group'

    it_can_parse_question_as_numeric "scale question", 5, :max => 5, :min => 1, :field => 'entry.7.group'

  end
end