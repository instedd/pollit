module Respondent::Pusher

  def push_answers
    RestClient.post poll.post_url, answers_form_data
    set_pushed_status(:succeeded, DateTime.now.utc)
    true
  rescue
    set_pushed_status(:failed)
    false
  end

  private

  def answers_form_data
    data = {'pageNumber' => 0, 'submit' => ''}
    answers.includes(:question).each do |answer|
      data[answer.question.field_name] = answer.response
    end
    data
  end

  def set_pushed_status(status, date=nil)
    self.pushed_status = status
    self.pushed_at = date
    save!
  end

end