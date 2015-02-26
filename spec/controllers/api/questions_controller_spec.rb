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

describe Api::QuestionsController do

  before_each_sign_in_as_new_user

  let!(:poll)         { Poll.make!(owner: controller.current_user) }
  let(:another_poll)  { Poll.make!(owner: controller.current_user) }

  it "should list questions" do
    Question.make!(3, poll: poll)
    Question.make!(2, poll: another_poll)

    get :index, poll_id: poll.id, format: :json
    assigns(:questions).to_a.should =~ poll.reload.questions.to_a
    response.should be_success
  end

  it "should show question" do
    question = Question.make!(poll: poll)
    get :show, poll_id: poll.id, id: question.id, format: :json
    assigns(:question).should eq(question)
    response.should be_success
  end

  it "should not show question from another user" do
    question = Question.make!(poll: Poll.make!(owner: User.make!))
    expect { get :show, id: question.id, poll_id: poll.id, format: :json }.to raise_error(ActiveRecord::RecordNotFound)
    assigns(:question).should be_nil
  end

end
