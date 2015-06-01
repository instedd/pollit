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

class AnswersController < ApplicationController
  before_filter :load_poll

  def index
    add_breadcrumb _("Answers"), poll_answers_path(@poll)
    @answers = @poll.answers.includes(:respondent, :question)

    @headers = [_('Respondent'), _('Question'), _('Answer')]
    @headers << _("Occurrence") if @poll.recurrence_iterative?
    @headers << _('Date')

    respond_to do |format|
      format.html { @answers = @answers.page(params[:page]) }
      format.csv do
        send_data(CSV.generate do |csv|
          csv << @headers
          @answers.each do |answer|
            row = [answer.respondent.unprefixed_phone, answer.question.title, answer.response]
            row << answer.occurrence if @poll.recurrence_iterative?
            row << answer.created_at.strftime("%Y-%m-%d %H:%M:%S")
            csv << row
          end
        end)
      end
    end
  end

end
