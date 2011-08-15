class NuntiumController < ApplicationController

  def receive_at
    logger.debug "Received nuntium message: #{params.inspect}"
    poll = find_poll_by_channel
    # from=...&to=...&subject=...&body=...&guid=....&channel=...&application=...
    user = find_user_by_from_sms
    send_response_from_user_to_poll
    reply_with_next_question_to_user
    render :nothing => true
  end

end
