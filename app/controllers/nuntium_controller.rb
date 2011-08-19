class NuntiumController < ApplicationController

  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"
    poll = Poll.find_by_channel(params[:channel])
    respondent = Respondent.find_by_phone(params[:from])
    next_message = poll.accept_answer(params[:body], respondent)

    if next_message.nil?
      render :nothing => true
    else
      render :text => next_message
    end
  end

end
