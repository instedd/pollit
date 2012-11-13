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
      poll = Poll.includes(:channel).where("channels.name = ?", params[:channel]).first
      respondent = poll.find_respondent(params[:from])

      if respondent.nil? || poll.nil?
        render :nothing => true and return
      end

      next_message = poll.accept_answer(params[:body], respondent)

      if next_message.nil?
        render :nothing => true
      else
        render :content_type => "text/plain", :text => next_message
      end

    rescue Exception => e
      render :nothing => true
    end
  end

  private

  def authenticate_nuntium_at_post
    authenticate_or_request_with_http_basic do |username, password|
      Nuntium.authenticate_at_post(username, password)
    end
  end
end
