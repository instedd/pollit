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

class Answer < ActiveRecord::Base
  belongs_to :respondent
  belongs_to :question

  validates :respondent_id, :presence => true, :uniqueness => {:scope => [:question_id, :occurrence]}
  validates :question_id, :presence => true
  validates :response, :presence => true

  scope :on_occurrence, -> (occurrence){ where(occurrence: occurrence) }

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  def for_api
    {
      id: self.id,
      question_id: self.question.id,
      question_title: self.question.title,
      respondent_phone: self.respondent.api_phone,
      occurrence: self.occurrence,
      timestamp: self.created_at,
      response: self.response
    }
  end

  private

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.question.try(:poll).try(:owner))
  end
end
