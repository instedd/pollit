require 'csv'

class RespondentsController < ApplicationController

  before_filter_load_poll

  def index
    redirect_to @poll if @poll.started?
  end

  def batch_update
    return if @poll.started?

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
    Respondent.delete_all :poll_id => @poll.id

    phones.each do |phone|
      prefixed_phone = "sms://#{phone.gsub(/[^0-9]/,"")}"
      @poll.respondents.create(:phone => prefixed_phone)
    end
  end

end
