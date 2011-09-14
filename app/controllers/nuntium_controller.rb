class NuntiumController < ApplicationController
  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"
    
    poll = Poll.includes(:channel).where("channels.name = ?", params[:channel]).first
    respondent = Respondent.find_by_phone(params[:from])

    if (respondent.nil? || poll.nil?)
      render :nothing => true
    else
      next_message = poll.accept_answer(params[:body], respondent)

      if next_message.nil?
        render :nothing => true
      else
        render :content_type => "text/plain", :text => next_message
      end
    end
  end
end
