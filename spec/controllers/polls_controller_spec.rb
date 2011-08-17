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
    post :create, :poll => Poll.plan, :questions => "[]"
    controller.current_user.should have(1).poll
    response.should redirect_to(:action => 'index')
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

end
