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
    update_phone_list(params[:phones])
    head :ok
  end

  def import_csv
    phones = CSV.read(params[:csv].tempfile).map(&:first)
    phones.map! { |phone| {:number => phone.gsub(/[^0-9]/,"")} }

    render :text => phones.to_json
  end

  private

  def update_phone_list(phones)
    if @poll.status_configuring?
      Respondent.delete_all :poll_id => @poll.id
    end

    phones.each do |phone|
      prefixed_phone = "sms://#{phone.gsub(/[^0-9]/,"")}"
      @poll.respondents.create(:phone => prefixed_phone)
    end

    @poll.on_respondents_added
  end

end
