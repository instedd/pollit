class AnswersController < ApplicationController

  add_breadcrumb _("Polls"), :polls_path
  
  before_filter :load_poll

  def index
    add_breadcrumb _("Answers"), poll_answers_path(@poll)
    @answers = @poll.answers.page(params[:page])
  end

end
