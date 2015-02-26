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

describe Api::RespondentsController do

  before_each_sign_in_as_new_user

  let!(:poll)         { Poll.make!(owner: controller.current_user) }
  let(:another_poll)  { Poll.make!(owner: controller.current_user) }

  it "should list respondents" do
    Respondent.make!(3, poll: poll)
    Respondent.make!(2, poll: another_poll)

    get :index, poll_id: poll.id, format: :json
    assigns(:respondents).should =~ poll.reload.respondents
    response.should be_success
  end

  it "should show respondent" do
    respondent = Respondent.make!(poll: poll)
    get :show, poll_id: poll.id, id: respondent.id, format: :json
    assigns(:respondent).should eq(respondent)
    response.should be_success
  end

  it "should not show respondent from another user" do
    respondent = Respondent.make!(poll: Poll.make!(owner: User.make!))
    expect { get :show, id: respondent.id, poll_id: poll.id, format: :json }.to raise_error(ActiveRecord::RecordNotFound)
    assigns(:respondent).should be_nil
  end

end
