class RespondentsController < ApplicationController

  before_filter :load_poll

  def index
    @phones_list = @poll.respondents.map{|r| r.unprefixed_phone}.join("\n")
  end

  def batch_update
    phones = params[:phones].scan(/[^,;\s\n\r]+/).reject{|p| p.empty?}.map{|p| "sms://#{p}"}
    phones.each do |phone|
      unless @poll.respondents.find_by_phone(phone)
        @poll.respondents.create(:phone => phone)
      end
    end

    redirect_to :action => :index
  end

  private

  def load_poll
    @poll = Poll.find params[:poll_id]
  end

end
