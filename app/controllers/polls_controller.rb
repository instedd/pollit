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

  def edit
    @poll = Poll.find(params[:id])
  end

  def update
    @poll = Poll.find(params[:id])

    if @poll.update_attributes(params[:poll])
      redirect_to :action => 'index'
    else
      render :view => 'edit'
    end
  end

  def start
    @poll = Poll.find(params[:id])
    @poll.start unless @poll.status == "started"
    
    redirect_to :action => 'show'
  end

  def import_form
    @poll = Poll.new params[:poll]
    @poll.parse_form
    render :partial => 'form'
  end

  def destroy
    poll = Poll.find(params[:id])
    poll.destroy

    redirect_to polls_path, :notice => "Poll has been deleted"
  end

end
