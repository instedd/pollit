class ChannelsController < ApplicationController
  def new
    @poll = Poll.find(params[:poll_id])
    @channel = Channel.new
  end

  def create
    @poll = Poll.find(params[:poll_id])
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      redirect_to @poll, :notice => "Channel has been registered."
    else
      render "new"
    end
  end
end