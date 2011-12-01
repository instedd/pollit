require 'spec_helper'

describe HomeController do

  it "should get home page" do
    get :index
    response.should be_success
  end

  it "should get home page as logged in" do
    request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in User.make
    get :index
    response.should be_success
  end

end
