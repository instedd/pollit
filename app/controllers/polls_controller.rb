class PollsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @polls = current_user.polls
  end

  def new
  	@poll = Poll.new
  end

  def create
    @poll = current_user.polls.build params[:poll]
    @poll.questions_attributes = JSON.parse params[:questions]
    if @poll.save
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end

  def import_form
    @poll = Poll.new params[:poll]
    logger.debug "Poll url: #{@poll.form_url}"
    @poll.parse_form
    render :partial => 'form'
  end

end
