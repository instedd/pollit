class NuntiumController < ApplicationController
  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"

    channel = Channel.find_by_address(params[:channel])
    respondent = Respondent.find_by_phone(params[:from])

    if (respondent.nil? || channel.nil?)
      render :nothing => true
    else
      poll = channel.user.current_poll
      
      next_message = poll.accept_answer(params[:body], respondent)

      if next_message.nil?
        render :nothing => true
      else
        render :content_type => "text/plain", :text => next_message
      end
    end
  end
end
