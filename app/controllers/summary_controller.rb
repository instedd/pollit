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

class SummaryController < ApplicationController
  before_filter :load_poll

  def index
    add_breadcrumb _("Summary"), poll_answers_path(@poll)
    @questions = @poll.questions.where(collects_respondent: false)
    gon.question_ids = @questions.to_a.map(&:id)
  end

  def query
    @question = @poll.questions.find(params[:question_id])
    render :rgviz => @poll.answers.where(question_id: @question.id) do |table|
      table.cols[0].label = 'Response'
      table.cols[1].label = 'Count' if table.cols[1]
    end
  end

end
