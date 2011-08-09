require 'spec_helper'

describe Poll do
  it "can be instantiated" do
    Poll.new.should be_an_instance_of(Poll)
  end

  it "can be saved successfully" do
    Poll.make.should be_persisted
  end

  context "parsing google form" do
    before(:each) do
      url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
      stub_request(:get, url).to_return_file('google-form.html')
      @poll = Poll.parse_form "http://#{url}"
    end

    def self.it_can_parse_question_as_text(kind, index, opts={})
      it "can parse #{kind} as text" do
        question = @poll.questions[index]
        question.title.should eq(opts[:title] || "Test #{kind}")
        question.description.should eq(opts[:description] || "Description #{index+1}")
        question.kind.should eq(:text)
      end
    end

    def self.it_can_parse_question_as_options(kind, index, opts={})
      it "can parse #{kind} as options" do
        question = @poll.questions[index]
        question.title.should eq(opts[:title] || "Test #{kind}")
        question.description.should eq(opts[:description] || "Description #{index+1}")
        question.kind.should eq(:options)
        
        opts[:options] = (0...(opts[:options_count])).map {|i| "Opt#{i+1}"} unless opts[:options]
        question.options.should eq(opts[:options])
      end
    end

    it "can parse public google form" do
      @poll.title.should eq('Test Form')
      @poll.description.should eq('The description of the form')
      @poll.questions.length.should eq(7)
    end

    it_can_parse_question_as_text "text question", 0
    it_can_parse_question_as_text "paragraph question", 1
    
    it_can_parse_question_as_options "choose from list question", 2, :options_count => 3
    it_can_parse_question_as_options "checkboxes question", 3, :options_count => 2
    it_can_parse_question_as_options "checkboxes question with other", 4, :options_count => 2
    it_can_parse_question_as_options "choice question", 5, :options_count => 2
    it_can_parse_question_as_options "choice question with other", 6, :options_count => 2

  end
end