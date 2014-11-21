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

describe Respondent do

  let (:post_url) do
    "https://docs.google.com/spreadsheet/formResponse?formkey=FORMKEY&ifq"
  end

  let (:form_url) do
    "https://docs.google.com/spreadsheet/viewform?hl=en_US&formkey=FORMKEY&ndplr=1#gid=0"
  end

  let(:poll) do
    Poll.make! :with_questions, :form_url => form_url, :post_url => post_url
  end

  it "can be instantiated" do
    Respondent.new.should be_an_instance_of(Respondent)
  end

  it "can be saved successfully" do
    Respondent.make!.should be_persisted
  end

  it "can find answer for question" do
    respondent = Respondent.make! :poll => poll
    answer = respondent.answers.make! :question => poll.questions.first
    respondent.answer_for(poll.questions.first).should eq(answer)
  end

  it "answer for question is nil if not found" do
    respondent = Respondent.make! :poll => poll
    respondent.answers.make! :question => poll.questions.first
    respondent.answer_for(poll.questions.second).should be_nil
  end

  it "should default confirmed to false" do
    Respondent.new.confirmed.should be_false
  end

  it "should default current_question_sent to false" do
    Respondent.new.current_question_sent.should be_false
  end


  RSpec.shared_examples "can push answers to google forms" do

    it "can be pushed to google forms" do
      stub_request(:post, post_url).to_return_file('google-form-post-response.html')
      respondent.push_answers.should be_true

      a_request(:post, post_url).with { |req|
        CGI.parse(req.body) == post_params
      }.should have_been_made

      respondent.pushed_at.should_not be_nil
      respondent.pushed_status.should eq(:succeeded)
    end

  end


  context "pusher" do

    let(:respondent) do
      Respondent.make! :poll => poll, :answers => [
        Answer.make!(:response => 'text', :question => poll.questions[0]),
        Answer.make!(:response => 'foo',  :question => poll.questions[1]),
        Answer.make!(:response => 'zab',  :question => poll.questions[2]),
        Answer.make!(:response => '4',    :question => poll.questions[3])]
    end

    let (:post_params) do
      { 'entry.0.single' => ['text'],
        'entry.1.single' => ['foo'],
        'entry.2.group' => ['zab'],
        'entry.3.group' => ['4'],
        'pageNumber' => ['0'],
        'submit' => ['']}
    end

    include_examples 'can push answers to google forms'

    it "marks answers as failed if cannot be pushed" do
      stub_request(:post, post_url).to_return(:status => 500, :body => "failed")
      respondent.push_answers.should be_false

      a_request(:post, post_url).with { |req|
        CGI.parse(req.body) == post_params
      }.should have_been_made

      respondent.pushed_at.should be_nil
      respondent.pushed_status.should eq(:failed)
    end

    it "remove prefix with unprefix function" do
      respondent.phone = "sms://111"
      respondent.unprefixed_phone.should eq("111")
    end

  end

  context "collecting respondent phone" do

    let(:poll) do
      Poll.make!(:with_questions, :form_url => form_url, :post_url => post_url).tap do |p|
        q = p.questions[1]
        q.collects_respondent = true
        q.save!
      end
    end

    let(:respondent) do
      Respondent.make! :poll => poll, :phone => 'sms://9991000', :answers => [
        Answer.make!(:response => 'text', :question => poll.questions[0]),
        Answer.make!(:response => 'zab',  :question => poll.questions[2]),
        Answer.make!(:response => '4',    :question => poll.questions[3])]
    end

    let (:post_params) do
      { 'entry.0.single' => ['text'],
        'entry.1.single' => ['9991000'],
        'entry.2.group' => ['zab'],
        'entry.3.group' => ['4'],
        'pageNumber' => ['0'],
        'submit' => ['']}
    end

    include_examples 'can push answers to google forms'

  end

end
