class PollsController < ApplicationController

  # require authentication

  def index
    @polls = current_user.polls
  end

end
