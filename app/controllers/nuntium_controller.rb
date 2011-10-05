class NuntiumController < ApplicationController
  before_filter :authenticate_nuntium_at_post

  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"
    
    begin
      poll = Poll.includes(:channel).where("channels.name = ?", params[:channel]).first
      respondent = poll.respondents.find_by_phone(params[:from])

      if respondent.nil? || poll.nil?
        render :nothing => true and return
      end

      next_message = poll.accept_answer(params[:body], respondent)

      if next_message.nil?
        render :nothing => true
      else
        render :content_type => "text/plain", :text => next_message
      end

    rescue Exception => e
      render :nothing => true
    end
  end

  private

  def authenticate_nuntium_at_post
    authenticate_or_request_with_http_basic do |username, password|
      Nuntium.authenticate_at_post(username, password)
    end
  end
end
