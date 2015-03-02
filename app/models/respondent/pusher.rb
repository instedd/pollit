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

module Respondent::Pusher

  def push_answers
    RestClient.post poll.post_url, answers_form_data(poll.current_occurrence)
    set_pushed_status(:succeeded, DateTime.now.utc)
    true
  rescue
    set_pushed_status(:failed)
    false
  end

  private

  def answers_form_data(occurrence=nil)
    data = {'pageNumber' => 0, 'submit' => ''}
    answers.on_occurrence(occurrence).includes(:question).each do |answer|
      data[answer.question.field_name] = answer.response
    end
    data[poll.respondent_question.field_name] = self.unprefixed_phone if poll.respondent_question
    data
  end

  def set_pushed_status(status, date=nil)
    self.pushed_status = status
    self.pushed_at = date
    save!
  end

end
