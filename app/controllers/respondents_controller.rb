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
  before_filter :load_respondents, only: [:index]

  skip_before_filter :verify_authenticity_token, :only => [:add_phones, :delete_all, :import_csv, :connect_hub, :clear_hub]

  def index
    respond_to do |format|
      format.js
      format.html do
        gon.phones = phones = @poll.respondents.map{|x| {:number => x.unprefixed_phone}}
        gon.can_edit = @can_edit = @poll.status_configuring?
        gon.poll = @poll.as_json

        gon.import_csv_poll_respondents_path = import_csv_poll_respondents_path(@poll)
        gon.add_phones_poll_respondents_path = add_phones_poll_respondents_path(@poll)
        gon.delete_all_poll_respondents_path = delete_all_poll_respondents_path(@poll)
        gon.connect_hub_path = connect_hub_poll_respondents_path(@poll)
        gon.clear_hub_path = clear_hub_poll_respondents_path(@poll)
        gon.respondents_path = poll_respondents_path(@poll)
        gon.poll_path = poll_path(@poll, :wizard => true)
        gon.hub_url = HubClient.current.url

        if wizard?
          @wizard_step = _("Respondents")
          render :layout => 'wizard'
        end
      end
    end
  end

  def destroy
    @poll.respondents.where(id: params[:id]).first.try(:destroy)
    load_respondents
    respond_to do |format|
      format.js do
        render 'index'
      end
    end
  end

  def add_phones
    params[:phones].each do |phone|
      phone = phone.gsub(/[^0-9]/,"")
      @poll.respondents.create(:phone => phone.with_protocol) unless phone.blank?
    end

    @poll.on_respondents_added
    head :ok
  end

  def delete_all
    @poll.respondents.destroy_all
    head :ok
  end

  def connect_hub
    @poll.hub_respondents_path = params[:path]
    @poll.hub_respondents_phone_field = params[:phone_field]
    @poll.save!

    HubImporter.import_respondents(@poll.id)
    head :ok
  end

  def clear_hub
    @poll.hub_respondents_path = nil
    @poll.hub_respondents_phone_field = nil
    @poll.save

    @poll.respondents.where('hub_source IS NOT NULL').delete_all if @poll.editable? && params[:delete_respondents]

    head :ok
  end

  private

  def load_respondents
    @respondents = @poll.respondents.order("created_at DESC").page(params[:page]).per(15)
  end

end
