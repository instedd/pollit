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
    p = Poll.make :with_questions, :confirmation_word => "Yes"
    p.start
    
    nuntium_http_login
    post :receive_at, {
      :channel => p.channel.name, 
      :from => p.respondents.first.phone, 
      :body => "Yes"
    }

    @response.body.should eq(p.questions.first.message)
    p.reload.respondents.first.confirmed.should be_true
  end
end
