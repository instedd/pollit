module Poll::AcceptAnswers

  INVALID_REPLY_OPTIONS = "Your answer was not understood. Please answer with (%s)"
  INVALID_REPLY_TEXT = "Your answer was not understood. Please answer with non empty string"
  INVALID_REPLY_NUMERIC = "Your answer was not understood. Please answer with a number between %s and %s"

  def accept_answer(response, respondent)
    if respondent.confirmed
      return nil if respondent.current_question_id.nil?
      current_question = questions.find(respondent.current_question_id)
      return self.send("accept_#{current_question.kind}_answer", response, respondent) if current_question.kind_valid?
    elsif response.strip.downcase == confirmation_word.strip.downcase
      respondent.confirmed = true
      return next_question_for respondent
    end
    nil
  end

  protected
  
  def next_question_for(respondent)
    if respondent.current_question
      next_question = respondent.current_question.lower_item
    else
      next_question = questions.first
    end

    respondent.current_question_id = next_question.try(:id)
    respondent.current_question_sent = self.status_is_not_paused?
    respondent.save!

    respondent.push_answers if next_question.nil?
    
    return next_question.try(:message) || goodbye_message unless self.status_paused?
  end

  private

  def accept_text_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if response.blank?
      INVALID_REPLY_TEXT
    else
      Answer.create :question => question, :respondent => respondent, :response => response
      next_question_for respondent
    end
  end

  def accept_numeric_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if(question.numeric_min..question.numeric_max).cover?(response.to_i)
      Answer.create :question => question, :respondent => respondent, :response => response.to_i
      next_question_for respondent
    else
      INVALID_REPLY_NUMERIC % [question.numeric_min, question.numeric_max]
    end
  end

  def accept_options_answer(response, respondent)
    question = questions.find(respondent.current_question_id)
    option = question.option_for(response)

    if option.nil?
      INVALID_REPLY_OPTIONS % [question.options.join("|")]
    else
      Answer.create :question => question, :respondent => respondent, :response => option
      next_question_for respondent
    end
  end

end