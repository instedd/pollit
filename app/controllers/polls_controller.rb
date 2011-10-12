class PollsController < ApplicationController

  add_breadcrumb "Polls", :polls_path

  before_filter :authenticate_user!
  before_filter :set_steps
  
  before_filter :except => [:index, :new, :create, :import_form] do
    load_poll(params[:id])
  end

  def index
    @polls = current_user.polls
  end
 
  def show
  end

  def new
    @poll = Poll.new
    params[:wizard] = true
    render :layout => "wizard"
  end

  def create
    @poll = current_user.polls.build params[:poll]

    if @poll.save
      redirect_to poll_new_channel_path(@poll, "a_choose_local_gateway", :wizard => 1)
    else
      params[:wizard] = true
      render 'new'
    end
  end

  def edit
    
    render :layout => "wizard"
  end

  def update
    # Mark for destruction all missing questions
    qs_attrs = params[:poll][:questions_attributes]
    @poll.questions.each do |q|
      q.mark_for_destruction unless qs_attrs.any?{|k,v| v['id'] == q.id.to_s}
    end

    # Update
    if @poll.update_attributes(params[:poll])
      if params[:wizard]
        redirect_to poll_new_channel_path(@poll, "a_choose_local_gateway", :wizard => 1)
      else
        redirect_to @poll, :notice => "Poll #{@poll.title} has been updated"
      end
    else
      render :action => 'edit'
    end
  end

  def import_form
    begin
      attrs = params[:poll].merge(:questions_attributes => {})      
      imported = Poll.new attrs
      imported.owner_id = current_user.id
      imported.questions = []
      imported.parse_form
      imported.generate_unique_title! if params[:poll][:title].blank?
      
      @poll = unless params[:id].blank? then load_poll(params[:id], attrs) else imported end
      @questions = imported.questions
    rescue => error
      @error = error
    ensure
      if request.xhr?
        render 'import_form', :layout => false
      else
        render :partial => 'form'
      end
    end
  end

  def destroy
    @poll.destroy
    redirect_to polls_path, :notice => "Poll #{@poll.title} has been deleted"
  end

  def register_channel
    @poll.register_channel(params[:ticket_code])
  end

  def start
    if @poll.start
      redirect_to :back, :notice => "Poll #{@poll.title} has been started"
    else
      redirect_to :back, :alert => "Poll #{@poll.title} has failed to start"
    end
  end

  def pause
    if @poll.pause
      redirect_to :back, :notice => "Poll #{@poll.title} has been paused"
    else
      redirect_to :back, :alert => "Poll #{@poll.title} has failed to pause"
    end
  end

  def resume
    if @poll.resume
      redirect_to :back, :notice => "Poll #{@poll.title} has been resumed"
    else
      redirect_to :back, :alert => "Poll #{@poll.title} has failed to resume"
    end
  end

  private

  def set_steps
    @steps = ['Properties','Channel','Respondents','Finish']
    @wizard_step = 'Properties'
  end
end
