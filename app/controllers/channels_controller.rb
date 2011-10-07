class ChannelsController < ApplicationController
  
  add_breadcrumb "Polls", :polls_path

  before_filter :authenticate_user!
  before_filter :load_poll
  before_filter :set_poll_steps

  def new
    @step = params[:step]
    @channel = @poll.channel
  end

  def create
    @poll.channel.destroy if @poll.channel
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      @step = "d_end_wizard"
      render "new"
    else
      @step = params[:next_step]
      render "new"
    end
  end

  def destroy
    Channel.find(params[:id]).destroy
    redirect_to poll_new_channel_path(@poll)
  end

  private

  def set_poll_steps
    @steps = ["Choose", "Install", "Connect", "Finish"]
  end

end