require 'spec_helper'

describe AnswersController do

  describe "GET 'index'" do
    it "should be successful" do
      p = Poll.make :with_questions
      get 'index', :poll_id => p.id
      response.should be_success
    end
  end

end
