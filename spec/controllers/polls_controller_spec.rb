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

describe PollsController do

  before_each_sign_in_as_new_user

  it "should get polls index" do
    3.times do controller.current_user.polls.make end
    get :index
    assigns(:polls).should have(3).items
    response.should be_success
  end

  it "should get new poll form" do
    get :new
    assigns(:poll).should_not be_nil
    response.should be_success
  end

  it "should create new poll" do
    post :create, :poll => Poll.plan
    Poll.all.should have(1).poll
    response.should redirect_to(new_poll_channel_path(Poll.first, :wizard => true))
  end

  it "should not create new poll if invalid" do
    post :create, :poll => Poll.plan(:title => '')
    Poll.all.should be_empty
    response.should render_template('new')
  end

  it "should not create new poll if no questions set" do
    post :create, :poll => Poll.plan(:questions => [])
    Poll.all.should be_empty
    response.should render_template('new')
  end

  it "should import poll form" do
    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "Manual title", :description => "Manual description", :form_url => "http://#{url}", :questions => []), :wizard => true

    response.should be_success
    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Manual title")
    assigns(:poll).description.should eq("Manual description")
  end

  it "should get title and description when importing poll form if were empty" do
    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "", :description => "", :form_url => "http://#{url}", :questions => []), :wizard => true

    response.should be_success
    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Test Form")
    assigns(:poll).description.should eq('The description of the form')
  end

  it "should generate new title when importing poll form if another one existed with that title" do
    Poll.make :owner => controller.current_user, :title => 'Test Form'

    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "", :description => "", :form_url => "http://#{url}", :questions => []), :wizard => true

    response.should be_success
    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Test Form 2")
    assigns(:poll).description.should eq('The description of the form')
  end

  it "should generate new title with higher index when importing poll form if another one existed with candidate titles" do
    Poll.make :owner => controller.current_user, :title => 'Test Form'
    Poll.make :owner => controller.current_user, :title => 'Test Form 2'
    Poll.make :owner => controller.current_user, :title => 'Test Form 3'

    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "", :description => "", :form_url => "http://#{url}", :questions => []), :wizard => true

    response.should be_success
    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Test Form 4")
    assigns(:poll).description.should eq('The description of the form')
  end

  it "should render show page" do
    p = Poll.make :owner => controller.current_user
    get :show, :id => p.id
    response.should be_success
    assigns(:poll).class.name.should eq("Poll")
  end

  it "should not render show page if unauthorized" do
    p = Poll.make :owner => User.make
    get :show, :id => p.id
    response.should redirect_to('/?locale=en')
    assigns(:poll).class.name.should eq("Poll")
  end

  describe "non recurrent polls" do
    it "should start poll" do
      p = Poll.make :with_questions, :owner => controller.current_user
      post :start, :id => p.id
      Poll.find(p.id).status.should eq(:started)
    end

    it "should pause poll" do
      p = Poll.make :with_questions, :owner => controller.current_user
      p.start
      post :pause, :id => p.id
      Poll.find(p.id).status.should eq(:paused)
    end

    it "should resume poll" do
      p = Poll.make :with_questions, :owner => controller.current_user
      p.start
      p.pause
      post :resume, :id => p.id
      Poll.find(p.id).status.should eq(:started)
    end
  end

  describe "recurrent polls" do
    it "should start poll and record current date" do
      p = Poll.make :with_questions, :owner => controller.current_user, :recurrence => { weekly: { days: [1], interval: 1 } }

      now = Time.parse("Apr 10 2014 10:00")
      Time.stubs(:now).returns(now)

      post :start, :id => p.id
      Poll.find(p.id).tap do |p|
        p.status.should eq(:started)
        p.recurrence.start_at.should eq(now)
      end
    end

    it "should resume poll and record current date" do
      p = Poll.make :with_questions, :owner => controller.current_user, :recurrence => { weekly: { days: [1], interval: 1 } }
      old = Time.parse("Apr 12 2014 10:00")
      Time.stubs(:now).returns(old)
      p.start
      p.pause

      now = Time.parse("Apr 15 2014 10:00")
      Time.stubs(:now).returns(now)

      post :resume, :id => p.id
      Poll.find(p.id).tap do |p|
        p.status.should eq(:started)
        p.recurrence.start_at.should eq(now)
      end
    end
  end

  it "should destroy poll" do
    p = Poll.make :with_questions, :owner => controller.current_user
    delete :destroy, :id => p.id
    Poll.find_by_id(p.id).should be_nil
  end

end
