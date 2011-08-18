require 'spec_helper'

describe Respondent do

  let (:post_url) do
    "https://docs.google.com/spreadsheet/formResponse?formkey=FORMKEY&ifq"
  end

  let (:form_url) do
    "https://docs.google.com/spreadsheet/viewform?hl=en_US&formkey=FORMKEY&ndplr=1#gid=0"
  end

  let(:poll) do
    Poll.make\
      :form_url => form_url, 
      :post_url => post_url,
      :questions => [
        Question.make(:field_name => 'entry.0.single'),
        Question.make(:options, :options => %w(foo bar baz), :field_name => 'entry.1.single'),
        Question.make(:options, :options => %w(oof rab zab), :field_name => 'entry.2.group'),
        Question.make(:numeric, :numeric_min => 1, :numeric_max => 10, :field_name => 'entry.3.group')]
  end

  it "can be instantiated" do
    Respondent.new.should be_an_instance_of(Respondent)
  end

  it "can be saved successfully" do
    Respondent.make.should be_persisted
  end

  context "pusher" do

    let(:respondent) do
      Respondent.make :poll => poll, :answers => [
        Answer.make(:response => 'text', :question => poll.questions[0]),
        Answer.make(:response => 'foo',  :question => poll.questions[1]),
        Answer.make(:response => 'zab',  :question => poll.questions[2]),
        Answer.make(:response => '4',    :question => poll.questions[3])]
    end

    let (:post_params) do
      {
        'entry.0.single' => ['text'],
        'entry.1.single' => ['foo'],
        'entry.2.group' => ['zab'],
        'entry.3.group' => ['4'],
        'pageNumber' => ['0']
      }
    end

    it "can be pushed to google forms" do
      stub_request(:post, post_url).to_return_file('google-form-post-response.html')
      respondent.push_answers.should be_true

      a_request(:post, post_url).with { |req|
        CGI.parse(req.body) == post_params
      }.should have_been_made

      respondent.pushed_at.should_not be_nil
      respondent.pushed_status.should eq(:succeeded)
    end

    it "marks answers as failed if cannot be pushed" do
      stub_request(:post, post_url).to_return(:status => 500, :body => "failed")
      respondent.push_answers.should be_false
      
      a_request(:post, post_url).with { |req|
        CGI.parse(req.body) == post_params
      }.should have_been_made

      respondent.pushed_at.should be_nil
      respondent.pushed_status.should eq(:failed)
    end

  end
end