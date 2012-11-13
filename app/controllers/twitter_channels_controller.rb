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

class TwitterChannelsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_poll

  def new
    channel = @poll.register_twitter_channel

    callback_url = authorize_callback_poll_twitter_channel_url(@poll, wizard: session['wizard'])
    redirect_url = Nuntium.new_from_config.twitter_authorize(@poll.as_channel_name, callback_url)
    redirect_to redirect_url
  end

  def authorize_callback
    channel = @poll.channel
    channel.address = params[:screen_name]
    channel.save!

    if params[:wizard]
      redirect_to poll_respondents_path(@poll, wizard: true)
    else
      redirect_to poll_channel_path(@poll)
    end
  end

  def twitter_callback
    @poll.channel.destroy if @poll.channel

    request_token = OAuth::RequestToken.new oauth, session['twitter_token'], session['twitter_secret']
    access_token = request_token.get_access_token oauth_verifier: params[:oauth_verifier]

    client = Twitter::Client.new(oauth_token: access_token.token, oauth_token_secret: access_token.secret)
    @channel = @poll.register_twitter_channel(access_token, client.user.screen_name)

    if session['wizard']
      redirect_to poll_respondents_path(@poll, wizard: true)
    else
      redirect_to poll_channel_path(@poll)
    end

    session['wizard'] = nil
    session['twitter_token'] = nil
    session['twitter_secret'] = nil
  end

  private

  def oauth
    @oauth ||= OAuth::Consumer.new Pollit::TwitterConsumerConfig['consumer_key'], Pollit::TwitterConsumerConfig['consumer_secret'], site: "http://api.twitter.com"
  end
end