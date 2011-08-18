class PollsController < ApplicationController

  before_filter :authenticate_user!

  def index
    @polls = current_user.polls
  end
 
  def show
    @poll = Poll.find(params[:id])
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = current_user.polls.build params[:poll]
    @poll.requires_questions = true
    @poll.questions_attributes = JSON.parse params[:questions]
    if @poll.save
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end

  def start
    @poll = Poll.find(params[:id])
    @poll.start unless @poll.confirmed
    render :text => @poll.next_question
  end

  def import_form
    @poll = Poll.new params[:poll]
    @poll.parse_form
    render :partial => 'form'
  end

end
