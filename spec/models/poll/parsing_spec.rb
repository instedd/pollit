require 'spec_helper'

describe Poll do

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
      question.must_contain.should eq(opts[:must_contain]) if opts[:must_contain]
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

    it_can_parse_question_as_text "text question", 0, :field => 'entry.0.single', :must_contain => 'foo'
    it_can_parse_question_as_text "paragraph question", 1, :field => 'entry.2.single'

    it_can_parse_question_as_options "choose from list question", 2, :options_count => 3, :field => 'entry.1.single'
    it_can_parse_question_as_options "choice question", 3, :options_count => 2, :field => 'entry.5.group'
    it_can_parse_question_as_options "choice question with other", 4, :options_count => 2, :field => 'entry.6.group'

    it_can_parse_question_as_numeric "scale question", 5, :max => 5, :min => 1, :field => 'entry.7.group'

  end

end
