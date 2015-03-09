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

describe Api::AnswersController do

  before_each_sign_in_as_new_user

  let(:poll)         { Poll.make!(owner: controller.current_user) }
  let(:another_poll) { Poll.make!(owner: controller.current_user) }

  it "should list answers" do
    Answer.make!(3, question: poll.questions.first)
    Answer.make!(2, question: another_poll.questions.first)

    get :index, poll_id: poll.id, format: :json
    assigns(:answers).to_a.should =~ poll.reload.answers.to_a
    response.should be_success
  end

  it "should show answer" do
    answer = Answer.make!(question: poll.questions.first)
    get :show, poll_id: poll.id, id: answer.id, format: :json
    assigns(:answer).should eq(answer)
    response.should be_success
  end

  it "should not show answer from another user" do
    answer = Answer.make!(question: Poll.make!(owner: User.make!).questions.first)
    expect { get :show, id: answer.id, poll_id: poll.id, format: :json }.to raise_error(ActiveRecord::RecordNotFound)
    assigns(:answer).should be_nil
  end

  context "filtering" do

    let(:poll) do
      Poll.make!(:with_questions, owner: controller.current_user, current_occurrence: DateTime.new(2015,1,2))
    end

    it "should list answers by question id" do
      answers = Answer.make!(3, question: poll.questions.first)
      Answer.make!(3, question: poll.questions.last)

      get :index, poll_id: poll.id, question_id: poll.questions.first.id, format: :json
      assigns(:answers).to_a.should =~ answers
      response.should be_success
    end

    it "should list answers by respondent id" do
      respondent = Respondent.make!(poll: poll)
      other_respondent = Respondent.make!(poll: poll)

      answers = poll.questions.map { |q| Answer.make!(question: q, respondent: respondent) }
      poll.questions.map { |q| Answer.make!(question: q, respondent: other_respondent) }

      get :index, poll_id: poll.id, respondent_id: respondent.id, format: :json
      assigns(:answers).to_a.should =~ answers
      response.should be_success
    end

    it "should list answers by respondent phone" do
      respondent = Respondent.make!(poll: poll, phone: 'sms://9991000')
      other_respondent = Respondent.make!(poll: poll)

      answers = poll.questions.map { |q| Answer.make!(question: q, respondent: respondent) }
      poll.questions.map { |q| Answer.make!(question: q, respondent: other_respondent) }

      get :index, poll_id: poll.id, respondent_phone: 'sms://9991000', format: :json
      assigns(:answers).to_a.should =~ answers
      response.should be_success
    end

    it "should list answers by respondent phone without protocol" do
      respondent = Respondent.make!(poll: poll, phone: 'sms://9991000')
      other_respondent = Respondent.make!(poll: poll)

      answers = poll.questions.map { |q| Answer.make!(question: q, respondent: respondent) }
      poll.questions.map { |q| Answer.make!(question: q, respondent: other_respondent) }

      get :index, poll_id: poll.id, respondent_phone: '9991000', format: :json
      assigns(:answers).to_a.should =~ answers
      response.should be_success
    end

    it "should list answers by occurrence" do
      answers = Answer.make!(3, question: poll.questions.first)
      Answer.make!(3, question: poll.questions.last, occurrence: DateTime.new(2014,1,1))

      get :index, poll_id: poll.id, occurrence: poll.current_occurrence, format: :json
      assigns(:answers).to_a.should =~ answers
      response.should be_success
    end

  end

end
