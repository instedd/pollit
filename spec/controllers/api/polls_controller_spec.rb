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

describe Api::PollsController do

  before_each_sign_in_as_new_user

  it "should list polls" do
    polls = 3.times.map { Poll.make!(owner: controller.current_user) }
    get :index, format: :json
    assigns(:polls).should =~ polls
    response.should be_success
  end

  it "should show poll" do
    poll = Poll.make! owner: controller.current_user
    get :show, id: poll.id, format: :json
    assigns(:poll).should eq(poll)
    response.should be_success
  end

  it "should not show poll from another user" do
    poll = Poll.make! owner:(User.make!)
    expect { get :show, id: poll.id, format: :json }.to raise_error(ActiveRecord::RecordNotFound)
    assigns(:poll).should be_nil
  end

end
