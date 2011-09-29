class PollsController < ApplicationController

  add_breadcrumb "Polls", :polls_path

  before_filter :authenticate_user!
  
  before_filter :only => [:show, :edit, :update, :start, :destroy, :register_channel] do
    load_poll(params[:id])
  end

  def index
    @polls = current_user.polls
  end
 
  def show
  end

  def new
    @poll = Poll.new
  end

  def create
    @poll = current_user.polls.build params[:poll]
    #@poll.questions_attributes = JSON.parse params[:questions]

    if @poll.save
      redirect_to :action => 'index'
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @poll.update_attributes(params[:poll])
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def start
    @poll.start unless @poll.status == "started"    
    redirect_to :action => 'show'
  end

  def import_form
    @poll = Poll.new params[:poll]
    @poll.owner_id = current_user.id
    @poll.questions.clear
    @poll.parse_form
    @poll.generate_unique_title! if params[:poll][:title].blank?
    render :partial => 'form'
  end

  def destroy
    @poll.destroy
    redirect_to polls_path, :notice => "Poll #{@poll.title} has been deleted"
  end

  def register_channel
    @poll.register_channel(params[:ticket_code])
  end
end
