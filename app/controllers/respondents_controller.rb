require 'csv'

class RespondentsController < ApplicationController

  before_filter :load_poll

  def index
    redirect_to @poll if @poll.started?
  end

  def batch_update
    return if @poll.started?
    Respondent.delete_all :poll_id => @poll.id

    phones = params[:phones].map { |phone| "sms://#{phone}" }

    phones.each do |phone|
      unless @poll.respondents.find_by_phone(phone)
        @poll.respondents.create(:phone => phone)
      end
    end

    head :ok
  end

  def import_phones
    
  end

  def import_csv
    return if @poll.started?
    redirect_to @poll if @poll.started?
    redirect_to @poll unless params[:csv].content_type == "text/csv"

    Respondent.delete_all :poll_id => @poll.id

    CSV.new(params[:csv].tempfile).each do |row|
      phone = row.first.gsub(/[^0-9]/, "")

      unless @poll.respondents.find_by_phone(phone)
        @poll.respondents.create(:phone => phone)
      end
    end

    redirect_to @poll
  end

  private

  def load_poll
    @poll = Poll.find params[:poll_id]
  end

end
