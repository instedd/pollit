class SendNextMessageJob < Struct.new(:poll_id, :respondent_id, :body)
  def perform
    poll = Poll.find_by_id poll_id
    return unless poll

    respondent = Respondent.find_by_id respondent_id
    return unless respondent

    message = poll.message_to(respondent, body)
    poll.send_messages([message])
  end
end