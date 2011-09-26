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
    if @poll.started?
      redirect_to @poll, :notice => "poll already started"
    end

    unless params[:csv].content_type == "text/csv"
      redirect_to @poll, :notice => "file should be in csv format"
    end

    phones = CSV.read(params[:csv].tempfile).map(&:first)
    update_phone_list(phones)

    redirect_to @poll, :notice => "csv phones has been imported"
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
