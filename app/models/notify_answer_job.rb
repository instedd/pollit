class NotifyAnswerJob < Struct.new(:answer_id)

  def perform
    answer = Answer.find(answer_id)
    HubClient.current.notify "polls/#{answer.question.poll_id}/$events/new_answer", data_for(answer).to_json
  rescue ActiveRecord::RecordNotFound
    # Answer was deleted, ok to fail silently
  end

  private

  def data_for(answer)
    answer.for_api.merge({
      poll_id: answer.question.poll.id,
      poll_title: answer.question.poll.title
    })
  end

end
