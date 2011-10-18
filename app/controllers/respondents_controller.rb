require 'csv'

class RespondentsController < ApplicationController

  add_breadcrumb "Polls", :polls_path

  before_filter :authenticate_user!
  before_filter :load_poll

  skip_before_filter :verify_authenticity_token, :only => [:import_csv]

  def index
    render 'readonly' unless @poll.status_configuring?
    if wizard?
      @wizard_step = "Respondents"
      render :layout => 'wizard'
    end
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
