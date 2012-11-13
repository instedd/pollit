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

require 'csv'

class RespondentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_poll

  skip_before_filter :verify_authenticity_token, :only => [:import_csv]

  def index
    if wizard?
      @wizard_step = _("Respondents")
      render :layout => 'wizard'
    end
  end

  def batch_update
    update_respondents_list(params[:respondents])
    head :ok
  end

  def import_csv
    respondents = CSV.read(params[:csv].tempfile).map do |phone, twitter|
      {:phone => phone.try(:to_phone_number), :twitter => twitter.try(:strip).try(:to_twitter)}
    end
    render :text => respondents.to_json
  end

  def export_csv
    send_data "+1 212 555 0123, twitter_user_1\n+1 212 555 4567, twitter_user_2", type: 'text/csv', filename: 'example_respondents.csv'
  end

  private

  def update_respondents_list(respondents)
    if @poll.status_configuring?
      Respondent.delete_all :poll_id => @poll.id
    end

    if respondents
      respondents.each do |number, respondent|
        prefixed_phone = respondent[:phone].present? ? "sms://#{respondent[:phone].to_phone_number}" : nil
        prefixed_twitter = respondent[:twitter].present? ? "twitter://#{respondent[:twitter].strip.to_twitter}" : nil
        @poll.respondents.create(:phone => prefixed_phone, :twitter => prefixed_twitter)
      end
    end

    @poll.on_respondents_added
  end

end
