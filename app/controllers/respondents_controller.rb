class RespondentsController < ApplicationController

  before_filter :load_poll

  def index
    @phones_list = @poll.respondents.map{|r| r.unprefixed_phone}.join("\n")
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

  private

  def load_poll
    @poll = Poll.find params[:poll_id]
  end

end
