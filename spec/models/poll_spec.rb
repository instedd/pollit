require 'spec_helper'

describe Poll do
  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make.should be_persisted
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
      poll.questions.length.should eq(5)
    end

    it_can_parse_question_as_text "text question", 0
    it_can_parse_question_as_text "paragraph question", 1
    
    it_can_parse_question_as_options "choose from list question", 2, :options_count => 3
    it_can_parse_question_as_options "choice question", 3, :options_count => 2
    it_can_parse_question_as_options "choice question with other", 4, :options_count => 2

    #it_can_parse_question_as_numeric "scale question", 5, :max => 5, :min => 1

  end
end