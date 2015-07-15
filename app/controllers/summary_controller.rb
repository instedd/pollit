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

require 'csv'

class SummaryController < ApplicationController
  before_filter :load_poll

  def index
    @questions = @poll.questions.to_a.reject(&:collects_respondent)

    respond_to do |format|

      format.html do
        add_breadcrumb _("Summary"), poll_summary_index_path(@poll)
        gon.question_ids = @questions.map(&:id)
      end

      format.csv do
        headers = [_("Respondent"), _("Timestamp")]
        headers << _("Occurrence") if @poll.has_recurrence?

        questions = @questions
        question_id_to_index = Hash[questions.each_with_index.map{|q, index| [q.id, index + headers.length]}]
        headers += questions.map(&:title)

        send_data(CSV.generate do |csv|
          csv << headers
          @poll.respondents.includes(:answers).each do |respondent|
            next if respondent.answers.empty?
            respondent.answers.group_by(&:occurrence).each do |occurrence, answers|
              row =  [respondent.unprefixed_phone, answers.last.created_at.strftime("%Y-%m-%d %H:%M:%S")]
              row << occurrence if @poll.has_recurrence?
              row += ([nil] * question_id_to_index.length)
              answers.each do |a|
                row_index = question_id_to_index[a.question_id]
                row[row_index] = a.response unless row_index.nil?
              end
              csv << row
            end
          end
        end)
      end
    end

  end

  def query
    @question = @poll.questions.find(params[:question_id])
    render :rgviz => @poll.answers.where(question_id: @question.id) do |table|
      table.cols[0].label = 'Response'
      table.cols[1].label = 'Count' if table.cols[1]
    end
  end

end
