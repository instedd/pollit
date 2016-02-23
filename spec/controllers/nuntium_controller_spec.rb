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

describe NuntiumController do
  before_each_sign_in_as_new_user

  include AuthHelper

  it "should fail auth" do
    http_login 'wrong', 'auth'
    post :receive_at
    @response.status.should eq(401)
  end

  it "should not receive answer without correct" do
    nuntium_http_login
    post :receive_at
    @response.body.should be_blank
  end

  it "should receive confirmation" do
    p = Poll.make! :with_questions, :confirmation_words => ["Yes"]
    p.start

    nuntium_http_login
    post :receive_at, {
      :channel => p.channels.first.name,
      :from => p.respondents.first.phone,
      :body => "Yes"
    }

    respondent = p.reload.respondents.first
    respondent.confirmed.should be_true
    respondent.channel.should eq(p.channels.first)
  end

  it "should receive confirmation with multiple confirmation words" do
    p = Poll.make! :with_questions, :confirmation_words => ["Yes", "Si"]
    p.start

    nuntium_http_login
    post :receive_at, {
      :channel => p.channels.first.name,
      :from => p.respondents.first.phone,
      :body => "Si"
    }

    p.reload.respondents.first.confirmed.should be_true
  end

  it "saves ao_message_state in respondent on delivery ack" do
    r = Respondent.make! ao_message_guid: "foo"

    nuntium_http_login
    post :delivery_callback, guid: "foo", state: "delivered"

    r.reload.ao_message_state.should eq("delivered")
  end
end
