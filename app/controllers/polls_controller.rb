class PollsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @polls = current_user.polls
  end

  def show
    @poll = Poll.find(params[:id])
    
  end

  def start
    
  end
end
