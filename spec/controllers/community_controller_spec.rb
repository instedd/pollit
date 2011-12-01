require 'spec_helper'

describe CommunityController do

  it "should get community page" do
    get :index
    response.should be_success
  end

end
