# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

class ChannelsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_poll

  def new
    if wizard?
      @wizard_step = _("Channel")
      render :layout => 'wizard'
    end
  end

  def show
    redirect_to :action => 'new', :wizard => params[:wizard] and return unless @poll.channel
    @channel = @poll.channel

    if @channel.is_a?(TwitterChannel) && @channel.address.blank?
      callback_url = authorize_callback_poll_twitter_channel_url(@poll)
      redirect_url = Nuntium.new_from_config.twitter_authorize(@poll.as_channel_name, callback_url)
      redirect_to redirect_url
      return
    end

    @channel.type.underscore =~ /(.+)_/
    type = $1
    if params[:wizard]
      render "#{type}_channels/show", :layout => 'wizard'
    else
      render "#{type}_channels/show"
    end
  end

  def destroy
    @poll.channel.destroy
    redirect_to new_poll_channel_path(@poll)
  end
end