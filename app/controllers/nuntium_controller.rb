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

class NuntiumController < ApplicationController
  before_filter :authenticate_nuntium_at_post

  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"

    begin
      channel = Channel.where(name: params[:channel]).first
      poll = channel.poll
      respondent = poll.respondents.find_by_phone(params[:from])

      if respondent.nil? || poll.nil?
        render :nothing => true and return
      end

      unless respondent.channel_id
        respondent.channel = channel
        respondent.save!
      end

      next_message = poll.accept_answer(params[:body], respondent)
      Delayed::Job.enqueue SendNextMessageJob.new(poll.id, respondent.id, next_message)
    rescue Exception => e
    end

    render :nothing => true
  end

  def delivery_callback
    respondent = Respondent.find_by_ao_message_guid params[:guid]
    if respondent
      respondent.ao_message_state = params[:state]
      respondent.save!
    end

    head :ok
  end

  private

  def authenticate_nuntium_at_post
    authenticate_or_request_with_http_basic do |username, password|
      Nuntium.authenticate_at_post(username, password)
    end
  end
end
