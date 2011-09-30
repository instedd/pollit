require 'spec_helper'

describe AnswersController do

  before_each_sign_in_as_new_user

  describe "GET 'index'" do
    it "should be successful" do
      p = Poll.make :with_questions, :owner => controller.current_user
      get 'index', :poll_id => p.id
      response.should be_success
    end
  end

end
