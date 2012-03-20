class AnswersController < ApplicationController
  before_filter :load_poll

  def index
    add_breadcrumb _("Answers"), poll_answers_path(@poll)
    @answers = @poll.answers.page(params[:page])
  end

end
