require 'spec_helper'

describe NuntiumController do
  before_each_sign_in_as_new_user

  it "should not receive answer without correct" do
    post :receive_at
    @response.body.should be_blank
  end

  it "should receive answer" do
    p = Poll.make :with_questions, :channel => "test"

    post :receive_at, :channel => "test", :from => p.respondents.first.phone, :body => "yes"

    p.respondents.first.confirmed.should be_true
  end
end
