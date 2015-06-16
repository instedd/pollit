# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Pollit.
#
# Pollit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Pollit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Pollit.  If not, see <http://www.gnu.org/licenses/>.

module Poll::AcceptAnswers

  def accept_answer(response, respondent)
    if respondent.confirmed
      return nil if respondent.current_question_id.nil?
      current_question = questions.find(respondent.current_question_id)
      return self.send("accept_#{current_question.kind}_answer", response, respondent) if current_question.kind_valid?
    elsif confirmation_words.map{|w| normalize(w)}.include?(normalize(response))
      respondent.confirmed = true
      return next_question_for respondent
    end
    nil
  end

  def initialize_respondent(respondent)
    respondent.current_question_id = nil
    next_question_for respondent
  end

  protected

  def normalize(answer)
    ActiveSupport::Inflector.transliterate(answer.strip, '').downcase
  end

  def next_question_for(respondent, current_answer=nil)
    next_question = respondent.current_question.nil? ? questions.first : respondent.current_question.next_question(current_answer.try(:response))
    next_question = next_question.next_question while next_question && next_question.collects_respondent

    respondent.current_question_id = next_question.try(:id)
    respondent.current_question_sent = self.status_is_not_paused?
    respondent.save!

    respondent.push_answers if next_question.nil?

    return next_question.try(:message) || goodbye_message unless self.status_paused?
  end

  private

  def accept_text_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if error = valid_text_answer?(question, response)
      invalid_reply error
    else
      answer = create_answer question, respondent, response
      next_question_for respondent, answer
    end
  end

  def accept_numeric_answer(response, respondent)
    question = questions.find(respondent.current_question_id)

    if error = valid_numeric_answer?(question, response)
      invalid_reply error
    else
      answer = create_answer question, respondent, response.to_i
      next_question_for respondent, answer
    end
  end

  def accept_options_answer(response, respondent)
    question = questions.find(respondent.current_question_id)
    option = question.option_for(response)

    if option.nil?
      invalid_reply_options % [question.options.join("|")]
    else
      answer = create_answer question, respondent, option
      next_question_for respondent, answer
    end
  end

  def create_answer(question, respondent, response)
    attributes = { :question => question, :respondent => respondent, :response => response }
    append_answer_attributes(attributes)
    answer = Answer.create! attributes
    notify_answer_to_hub(answer)
    answer
  rescue => ex
    Rails.logger.error "Error creating answer with attributes #{attributes} for poll #{self}: #{ex}"
    nil
  end

  def notify_answer_to_hub(answer)
    return if not HubClient.current.enabled?
    Delayed::Job.enqueue NotifyAnswerJob.new(answer.id)
  end

  def valid_text_answer?(question, response)
    response = response.strip
    return _("Please answer with a non empty response.") unless response.length > 0


    if question.min_length && question.max_length
      if response.length < question.min_length || response.length > question.max_length
        _("Please answer with a response between %s and %s characters.") % [question.min_length, question.max_length]
      end
    elsif question.min_length
      if response.length < question.min_length
        _("Please answer with a response with at least %s characters.") % question.min_length
      end
    elsif question.max_length
      if response.length > question.max_length
        _("Please answer with a response with no more than %s characters.") % question.max_length
      end
    elsif question.must_contain
      if !response.include?(question.must_contain)
        _("Your response must include '%s'.") % question.must_contain
      end
    end
  end

  def valid_numeric_answer?(question, response)
    return _("Please answer with a number.") unless response =~ /\A\s*-?\d+\s*/
    response = response.to_i

    if question.numeric_min && question.numeric_max
      if response < question.numeric_min || response > question.numeric_max
        _("Please answer with a number between %s and %s.") % [question.numeric_min, question.numeric_max]
      end
    elsif question.numeric_min
      if response < question.numeric_min
        _("Please answer with a number greater or equal to %s.") % question.numeric_min
      end
    elsif question.numeric_max
      if response > question.numeric_max
        _("Please answer with a number less or equal to %s.") % question.numeric_max
      end
    end
  end

  def invalid_reply(extra_text=nil)
    [_("Your answer was not understood."), extra_text].compact.join(' ')
  end

  def invalid_reply_options
    invalid_reply _("Please answer with (%s).")
  end

end
