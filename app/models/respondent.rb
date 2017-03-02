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

class Respondent < ActiveRecord::Base
  has_many :answers, :dependent => :destroy
  belongs_to :current_question, :class_name => Question.name
  belongs_to :poll
  belongs_to :channel

  validates :phone, :presence => true, :uniqueness => { :scope => :poll_id }

  enum_attr :pushed_status, %w(^pending succeeded failed local)

  after_save :touch_user_lifespan
  after_destroy :touch_user_lifespan

  include Pusher

  def answer_for(question)
    answers.find_by_question_id question.id
  end

  def unprefixed_phone
    return nil if not phone
    phone.without_protocol
  end

  def api_phone
    unprefixed_phone.try(:gsub, /^\+/, '')
  end

  def for_api
    self.as_json.merge("phone" => api_phone)
  end

  private

  def touch_user_lifespan
    Telemetry::Lifespan.touch_user(self.poll.try(:owner))
  end

end
