class ChannelsController < ApplicationController
  before_filter_load_poll

  def new
    @channel = Channel.new
  end

  def create
    @channel = @poll.register_channel(params[:channel][:ticket_code])

    if @channel.valid?
      redirect_to @poll, :notice => "Channel has been registered."
    else
      render "new"
    end
  end

end