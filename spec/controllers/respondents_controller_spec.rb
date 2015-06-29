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

describe RespondentsController do

  before_each_sign_in_as_new_user

  let(:phones) { ['9991000', '9991001', '9991002', '9991003', '9991004'] }
  let(:poll) { Poll.make!(owner: controller.current_user, respondents: phones.map{|p| Respondent.make(phone: "sms://#{p}")}) }

  it "should get index" do
    get :index, poll_id: poll.id
    response.should be_success
    assigns(:poll).should eq(poll)
  end

  it "should destroy a respondent" do
    delete :destroy, poll_id: poll.id, id: poll.respondents.first.id, format: :js
    response.should be_success
    poll.reload.should have(4).respondents
  end

  it "should bulk add phones" do
    post :add_phones, poll_id: poll.id, phones: ['9991000', '9992000', '9992000', 'notaphone', 'sms://9993000']
    response.should be_success
    poll.reload.respondents.pluck(:phone).should =~ ['sms://9991000', 'sms://9991001', 'sms://9991002', 'sms://9991003', 'sms://9991004', 'sms://9992000', 'sms://9993000']
    messages.should be_empty
  end

  context "with poll started" do

    let(:poll) { Poll.make!(status: :started, owner: controller.current_user, respondents: phones.map{|p| Respondent.make(phone: "sms://#{p}", current_question_sent: true)}) }

    it "should invite new phones" do
      post :add_phones, poll_id: poll.id, phones: ['9991000', '9992000']
      response.should be_success
      messages.should have(1).item
    end

  end

  it "should connect hub" do
    HubImporter.should_receive(:import_respondents).with(poll.id).once
    post :connect_hub, poll_id: poll.id, path: 'HUB_PATH', phone_field: ['phones', 'main']
    poll.reload.hub_respondents_path.should eq('HUB_PATH')
    poll.reload.hub_respondents_phone_field.should eq(['phones', 'main'])
  end

  context "with hub connected" do

    let(:poll) { Poll.make!(owner: controller.current_user, respondents: phones.map{|p| Respondent.make(phone: "sms://#{p}", hub_source: 'HUB_PATH')} + [Respondent.make(phone: "sms://9992000")]) }

    it "should disconnect hub" do
      post :clear_hub, poll_id: poll.id
      poll.reload.hub_respondents_path.should be_blank
      poll.reload.hub_respondents_phone_field.should be_blank
    end

    it "should clear hub respondents" do
      post :clear_hub, poll_id: poll.id, delete_respondents: true
      poll.reload.should have(1).respondent
    end

  end

end
