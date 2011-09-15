class ChannelsController < ApplicationController
  def new
    @poll = Poll.find(params[:poll_id])
    @channel = Channel.new
  end

  def create
    @poll = Poll.find(params[:poll_id])
    if @poll.register_channel(params[:channel][:ticket_code])
      redirect_to @poll, :notice => "Channel has been registered."
    else
      @channel = Channel.new
      flash[:error] = "channel could not been registered"
      render "new"
    end
  end
end