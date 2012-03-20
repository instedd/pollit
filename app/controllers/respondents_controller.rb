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
