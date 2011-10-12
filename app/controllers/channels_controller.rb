class ChannelsController < ApplicationController
  add_breadcrumb "Polls", :polls_path

  before_filter :authenticate_user!
  before_filter :load_poll
  before_filter :set_steps

  def new
    @step = params[:step]
    @channel = @poll.channel
    set_current_step if @step
    render :layout => "wizard" unless request.xhr?
  end

  def create
    @poll.channel.destroy if @poll.channel
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      if params[:wizard]
        redirect_to poll_respondents_path(@poll, :wizard => 1)
      else
        redirect_to poll_new_channel_path(@poll, "d_end_wizard", :wizard => 1)
      end
    else
      @step = params[:next_step]
      set_current_step
      render "new"
    end
  end

  def destroy
    Channel.find(params[:id]).destroy
    redirect_to poll_new_channel_path(@poll)
  end

  private

  def set_steps
    @steps = ["Choose", "Install", "Connect", "Finish"]
    @dotted_steps = ["Properties", "Choose", "Install", "Connect", "Respondents"]
  end

  def set_current_step
    { 
      "a" => "Choose", "b" => "Install", "c" => "Connect", "d" => "Finish"
    }.each_pair do |k,v|
      @wizard_step = v if @step.start_with?(k)
    end
  end
end