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

  validates :phone, :uniqueness => { :scope => :poll_id }, :if => :phone?
  validates :twitter, :uniqueness => { :scope => :poll_id }, :if => :twitter?

  enum_attr :pushed_status, %w(^pending succeeded failed)

  include Pusher

  def answer_for(question)
    answers.find_by_question_id question.id
  end

  def unprefixed_phone
    return nil if not phone
    phone.gsub(/^sms:\/\//, '')
  end

  def unprefixed_twitter
    return nil if not twitter
    twitter.gsub(/^twitter:\/\//, '')
  end

  def display_text
    if phone.present?
      if twitter.present?
        "#{unprefixed_phone} (@#{unprefixed_twitter})"
      else
        unprefixed_phone
      end
    elsif twitter.present?
      "@#{unprefixed_twitter}"
    else
      ''
    end
  end
end
