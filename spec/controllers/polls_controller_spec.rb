require 'spec_helper'

describe PollsController do

  before_each_sign_in_as_new_user

  it "should get polls index" do
    3.times do controller.current_user.polls.make end
    get :index
    assigns(:polls).should have(3).items
  end

  it "should get new poll form" do
    get :new
    assigns(:poll).should_not be_nil
  end

  it "should create new poll" do
    post :create, :poll => Poll.plan, :questions => [Question.make_unsaved(:without_poll)].to_json
    Poll.all.should have(1).poll
    response.should redirect_to(:action => 'index')
  end

  it "should not create new poll if invalid" do
    post :create, :poll => Poll.plan(:title => ''), :questions => [Question.make_unsaved(:without_poll)].to_json
    Poll.all.should be_empty
    response.should render_template('new')
  end

  it "should not create new poll if no questions set" do
    post :create, :poll => Poll.plan, :questions => '[]'
    Poll.all.should be_empty
    response.should render_template('new')
  end

  it "should import poll form" do
    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "Manual title", :description => "Manual description", :form_url => "http://#{url}")

    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Manual title")
    assigns(:poll).description.should eq("Manual description")
  end

  it "should get title and description when importing poll form if were empty" do
    url = 'spreadsheets.google.com/spreadsheet/viewform?formkey=FORMKEY'
    stub_request(:get, url).to_return_file('google-form.html')
    post :import_form, :poll => Poll.plan(:title => "", :description => "", :form_url => "http://#{url}")

    assigns(:poll).should have(6).questions
    assigns(:poll).title.should eq("Test Form")
    assigns(:poll).description.should eq('The description of the form')
  end

  it "should render show page" do
    p = Poll.make
    get :show, :id => p.id
    assigns(:poll).class.name.should eq("Poll")
  end

  it "shoud start poll" do
    p = Poll.make :with_questions
    post :start, :id => p.id
    Poll.find(p.id).status.should eq("started")
  end

end
